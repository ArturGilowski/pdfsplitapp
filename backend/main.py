import os
import io
import re
import uuid
import zipfile
import shutil
import unicodedata
from typing import List

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
import pdf2image
import pytesseract
from pypdf import PdfReader, PdfWriter

app = FastAPI(title="PDF AI Splitter API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Constants for local binary paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
POPPLER_PATH = os.path.join(BASE_DIR, "poppler", "poppler-24.08.0", "Library", "bin")
TESSERACT_CMD = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
UPLOADS_DIR = os.path.join(BASE_DIR, "uploads")

os.makedirs(UPLOADS_DIR, exist_ok=True)
pytesseract.pytesseract.tesseract_cmd = TESSERACT_CMD

def check_dependencies():
    missing = []
    if not os.path.exists(TESSERACT_CMD):
        missing.append(f"Tesseract nieznaleziony w {TESSERACT_CMD}")
    if not os.path.exists(POPPLER_PATH):
        missing.append(f"Poppler bin folder nieznaleziony w {POPPLER_PATH}")
    return missing

@app.get("/")
def read_root():
    return {"status": "ok", "message": "Backend is running"}

@app.get("/api/health")
def health_check():
    missing = check_dependencies()
    if missing:
        return {"status": "error", "missing_dependencies": missing}
    return {"status": "ok", "message": "All dependencies available"}

# Modele Pydantic na żądanie podziału
class SectionDef(BaseModel):
    id: str
    title: str
    startPage: int # 1-indexed
    endPage: int   # 1-indexed

class SplitRequest(BaseModel):
    file_id: str
    sections: List[SectionDef]

# Złota lista zwrotów wskazanych przez użytkownika
KEYWORDS = [
    "Umowa cesji", 
    "Załącznik nr 1", 
    "Załącznik nr 2", 
    "UMOWA CESJI WIERZYTELNOŚCI NA SZKODĘ", 
    "ANEKS DO UMOWY CESJI", 
    "UPOWAŻNIENIE", 
    "ZAWIADOMIENIE DŁUŻNIKA O PRZELEWIE WIERZYTELNOŚCI", 
    "OŚWIADCZENIE POSZKODOWANEGO", 
    "RODO"
]

def normalize_text(text: str) -> str:
    if not text:
        return ""
    # Usuwa znaki diakrytyczne (np. ą->a, ł->l, ę->e) i zostawia czyste ASCII
    return unicodedata.normalize('NFKD', text).encode('ascii', 'ignore').decode('utf-8')

# Budujemy regex dopasowujący dowolne z powyższych po znormalizowaniu na ASCII
REGEX_PATTERN = "(?i)(" + "|".join([normalize_text(k).replace(" ", r"\s+") for k in KEYWORDS]) + ")"


@app.post("/api/analyze")
async def analyze_pdf(file: UploadFile = File(...)):
    """
    Krok 1: Wgrywa PDF, konwertuje na obrazy, wyłapuje słowa kluczowe OCR-em, 
    i zwraca predykcje podziału.
    """
    missing = check_dependencies()
    if missing:
        raise HTTPException(status_code=500, detail=f"Brakujące zależności: {', '.join(missing)}")

    if not file.filename.lower().endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Plik musi być w formacie PDF")

    file_id = f"{uuid.uuid4()}.pdf"
    pdf_path = os.path.join(UPLOADS_DIR, file_id)
    
    # Zapis
    content = await file.read()
    with open(pdf_path, "wb") as f:
        f.write(content)

    # Konwersja
    try:
        images = pdf2image.convert_from_path(pdf_path, poppler_path=POPPLER_PATH)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Błąd konwersji PDF do obrazów: {str(e)}")

    total_pages = len(images)
    detected_sections = []
    
    # OCR loop
    for i, img in enumerate(images):
        page_num = i + 1 # 1-indexed
        try:
            try:
                text = pytesseract.image_to_string(img, lang="pol")
            except:
                text = pytesseract.image_to_string(img)
                
            norm_text = normalize_text(text)
            match = re.search(REGEX_PATTERN, norm_text)
            if match:
                # Oczyszczenie tytułu np. z nadmiarowych spacji po środku
                clean_title = re.sub(r'\s+', ' ', match.group(0)).strip()
                # Postarajmy się przywrócić ładną polską nazwę na podstawie dopasowania
                # Sprawdzamy, które słowo ze słownika zmatchowało by nadać mu idealny, wielokolumnowy tytuł
                matched_nice_title = clean_title.title()
                for kw in KEYWORDS:
                    if normalize_text(kw).lower().replace(" ", "") == clean_title.lower().replace(" ", ""):
                        matched_nice_title = kw
                        break

                detected_sections.append({
                    "id": str(uuid.uuid4()),
                    "title": matched_nice_title,
                    "startPage": page_num,
                    "endPage": total_pages # Tymczasowo do końca dokumentu
                })
        except Exception as e:
            print(f"Błąd OCR strona {page_num}: {e}")
            pass

    # Jeśli nic nie znaleziono (lub na 1 stronie nic nie było), dajemy domyślną sekcję
    if not detected_sections:
        detected_sections.append({
            "id": str(uuid.uuid4()),
            "title": "Główny Część (Nie wykryto)",
            "startPage": 1,
            "endPage": total_pages
        })
    else:
        # Jeśli pierwsza znaleziona sekcja nie jest na stronie 1, dodaj 'Początek'
        if detected_sections[0]["startPage"] > 1:
            detected_sections.insert(0, {
                "id": str(uuid.uuid4()),
                "title": "Początek Dokumentu",
                "startPage": 1,
                "endPage": detected_sections[0]["startPage"] - 1
            })
            
        # Zwiń endPage dla poprzednich sekcji
        for idx in range(len(detected_sections) - 1):
            detected_sections[idx]["endPage"] = detected_sections[idx+1]["startPage"] - 1

    return {
        "file_id": file_id,
        "original_filename": file.filename,
        "total_pages": total_pages,
        "sections": detected_sections
    }

@app.post("/api/split")
async def split_pdf(request: SplitRequest):
    """
    Krok 2: Tnie wcześniej wysłany plik wg ustalonych przez użytkownika przedziałów stron
    """
    pdf_path = os.path.join(UPLOADS_DIR, request.file_id)
    if not os.path.exists(pdf_path):
        raise HTTPException(status_code=404, detail="Plik nie istnieje lub sesja wygasła.")

    reader = PdfReader(pdf_path)
    total_pdf_pages = len(reader.pages)
    zip_buffer = io.BytesIO()
    
    with zipfile.ZipFile(zip_buffer, "w", zipfile.ZIP_DEFLATED) as zip_file:
        for sec in request.sections:
            writer = PdfWriter()
            # Upewnienie się że strony są w bezpiecznych zakresach
            start = max(1, sec.startPage)
            end = min(total_pdf_pages, sec.endPage)
            
            if start > end:
                continue # Pomiń błędne ramy
                
            for page_idx in range(start - 1, end): # convert 1-indexed do 0-indexed
                writer.add_page(reader.pages[page_idx])
                
            # Czyszczenie nazwy pliku
            safe_title = re.sub(r'[<>:"/\\|?*]', '_', sec.title)
            safe_title = safe_title[:50] # limit długości
            part_filename = f"{safe_title}_{sec.startPage}-{sec.endPage}.pdf"
            
            # Bezpieczne zapisanie w pamięci ram i skompresowanie
            pdf_bytes = io.BytesIO()
            writer.write(pdf_bytes)
            zip_file.writestr(part_filename, pdf_bytes.getvalue())

    zip_buffer.seek(0)
    
    # Optional cleanup (usuwamy stary plik zaraz po kompresji)
    try:
        os.remove(pdf_path)
    except:
        pass
        
    return StreamingResponse(
        iter([zip_buffer.getvalue()]), 
        media_type="application/zip",
        headers={"Content-Disposition": f"attachment; filename=Podzielone_Dokumenty.zip"}
    )

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

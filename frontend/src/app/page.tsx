"use client";

import { useState, useRef, useCallback } from "react";
import { motion, AnimatePresence, Reorder } from "framer-motion";
import {
  UploadCloud,
  FileText,
  Settings2,
  Loader2,
  CheckCircle2,
  AlertCircle,
  Download,
  Plus,
  Trash2,
  Edit3
} from "lucide-react";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface Section {
  id: string;
  title: string;
  startPage: number | "";
  endPage: number | "";
}

type Step = "upload" | "analyzing" | "review" | "splitting" | "done" | "error";

export default function Home() {
  const [step, setStep] = useState<Step>("upload");
  const [file, setFile] = useState<File | null>(null);
  const [fileId, setFileId] = useState<string>("");
  const [totalPages, setTotalPages] = useState<number>(0);
  const [sections, setSections] = useState<Section[]>([]);

  const [errorMessage, setErrorMessage] = useState("");
  const [downloadUrl, setDownloadUrl] = useState("");

  const fileInputRef = useRef<HTMLInputElement>(null);
  const [isDragging, setIsDragging] = useState(false);

  // --- DRAG & DROP ---
  const onDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault(); setIsDragging(true);
  }, []);
  const onDragLeave = useCallback((e: React.DragEvent) => {
    e.preventDefault(); setIsDragging(false);
  }, []);
  const onDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault(); setIsDragging(false);
    if (e.dataTransfer.files?.[0]?.type === "application/pdf") {
      setFile(e.dataTransfer.files[0]);
    } else {
      showError("Tylko pliki PDF są obsługiwane.");
    }
  }, []);
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files?.[0]?.type === "application/pdf") {
      setFile(e.target.files[0]);
    } else {
      showError("Tylko pliki PDF są obsługiwane.");
    }
  };

  const showError = (msg: string) => {
    setErrorMessage(msg);
    setStep("error");
  };

  // --- KROK 1: ANALIZA ---
  const startAnalysis = async () => {
    if (!file) return;
    setStep("analyzing");
    setErrorMessage("");

    const formData = new FormData();
    formData.append("file", file);

    try {
      const response = await fetch("http://localhost:8000/api/analyze", {
        method: "POST",
        body: formData,
      });

      if (!response.ok) {
        const err = await response.json();
        throw new Error(err.detail || "Błąd podczas analizowania układu pliku.");
      }

      const data = await response.json();
      setFileId(data.file_id);
      setTotalPages(data.total_pages);
      setSections(data.sections || []);
      setStep("review");
    } catch (err: any) {
      showError(err.message || "Błąd połączenia z serwerem.");
    }
  };

  // --- KROK 2: EDYCJA ---
  const addSection = () => {
    const lastPageValid = sections.length > 0 ? Number(sections[sections.length - 1].endPage) || 0 : 0;
    const newStart = lastPageValid < totalPages ? lastPageValid + 1 : totalPages;
    setSections([...sections, {
      id: Math.random().toString(36).substring(7),
      title: "Nowa Sekcja",
      startPage: newStart,
      endPage: totalPages
    }]);
  };

  const updateSection = (id: string, field: keyof Section, value: string | number) => {
    setSections(sections.map(s => s.id === id ? { ...s, [field]: value } : s));
  };

  const removeSection = (id: string) => {
    setSections(sections.filter(s => s.id !== id));
  };

  // --- KROK 3: CIĘCIE ---
  const startSplit = async () => {
    if (sections.length === 0) {
      alert("Musisz dodać przynajmniej jedną sekcję!");
      return;
    }

    setStep("splitting");
    try {
      const response = await fetch("http://localhost:8000/api/split", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          file_id: fileId,
          sections: sections.map(s => ({
            ...s,
            startPage: Number(s.startPage) || 1,
            endPage: Number(s.endPage) || totalPages
          }))
        }),
      });

      if (!response.ok) {
        const err = await response.json();
        throw new Error(err.detail || "Błąd podziału dokumentu.");
      }

      const blob = await response.blob();
      setDownloadUrl(window.URL.createObjectURL(blob));
      setStep("done");
    } catch (err: any) {
      showError(err.message || "Błąd połączenia z serwerem podczas cięcia.");
    }
  };

  const reset = () => {
    setStep("upload");
    setFile(null);
    setFileId("");
    setSections([]);
    setDownloadUrl("");
  };

  return (
    <main className="min-h-screen relative flex items-center justify-center p-4 sm:p-8 overflow-hidden bg-slate-900 text-slate-100 font-sans selection:bg-indigo-500/30">
      {/* Background Gradients */}
      <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-indigo-600/20 rounded-full blur-[120px] pointer-events-none" />
      <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-violet-600/20 rounded-full blur-[120px] pointer-events-none" />

      <div className="relative z-10 w-full max-w-4xl flex flex-col gap-8">

        {/* HEADER */}
        <div className="text-center space-y-4">
          <motion.h1
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-4xl md:text-5xl font-extrabold tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-indigo-300 via-white to-violet-300"
          >
            PDF AI Splitter
          </motion.h1>
          <p className="text-slate-400 max-w-xl mx-auto text-lg">
            Inteligentne rozpoznawanie sekcji w zeskanowanych dokumentach.
          </p>
        </div>

        {/* MAIN CONTAINER */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="bg-slate-800/60 backdrop-blur-xl border border-slate-700 p-6 md:p-8 rounded-3xl shadow-2xl relative overflow-hidden"
        >
          <AnimatePresence mode="wait">

            {/* 1. UPLOAD & ERROR */}
            {(step === "upload" || step === "error") && (
              <motion.div
                key="upload"
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20, filter: "blur(5px)" }}
                className="flex flex-col gap-6"
              >
                {!file ? (
                  <div
                    onDragOver={onDragOver}
                    onDragLeave={onDragLeave}
                    onDrop={onDrop}
                    onClick={() => fileInputRef.current?.click()}
                    className={cn(
                      "border-2 border-dashed rounded-2xl flex flex-col items-center justify-center py-16 px-6 text-center cursor-pointer transition-all duration-300 group",
                      isDragging
                        ? "border-indigo-400 bg-indigo-500/10 shadow-[0_0_30px_rgba(99,102,241,0.2)]"
                        : "border-slate-600 hover:border-indigo-500/50 hover:bg-slate-700/30"
                    )}
                  >
                    <input type="file" ref={fileInputRef} onChange={handleFileChange} accept="application/pdf" className="hidden" />
                    <div className="bg-slate-800 p-4 rounded-full mb-4 group-hover:scale-110 transition-transform duration-300">
                      <UploadCloud size={40} className="text-indigo-400" />
                    </div>
                    <h3 className="text-xl font-bold text-slate-200 mb-2">Przeciągnij i upuść PDF</h3>
                    <p className="text-slate-400">lub kliknij, aby wybrać plik.</p>
                  </div>
                ) : (
                  <div className="bg-slate-900/60 border border-slate-700 rounded-2xl p-6 flex flex-col sm:flex-row items-center justify-between gap-4">
                    <div className="flex items-center gap-4 w-full">
                      <div className="p-3 bg-emerald-500/20 rounded-xl">
                        <FileText size={32} className="text-emerald-400" />
                      </div>
                      <div className="truncate">
                        <h4 className="font-semibold text-slate-200 truncate pr-4">{file.name}</h4>
                        <p className="text-sm text-slate-500">{(file.size / 1024 / 1024).toFixed(2)} MB</p>
                      </div>
                    </div>
                    <div className="flex gap-3 w-full sm:w-auto shrink-0 justify-end">
                      <button onClick={reset} className="px-4 py-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800 transition-colors">
                        Zmień
                      </button>
                      <button onClick={startAnalysis} className="px-6 py-2 bg-indigo-500 hover:bg-indigo-400 text-white font-medium rounded-xl shadow-lg shadow-indigo-500/25 transition-all hover:-translate-y-0.5 whitespace-nowrap">
                        Analizuj OCR
                      </button>
                    </div>
                  </div>
                )}

                {step === "error" && (
                  <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} className="flex items-start gap-3 p-4 bg-red-500/10 border border-red-500/20 text-red-400 rounded-xl">
                    <AlertCircle className="shrink-0 mt-0.5" size={20} />
                    <p className="text-sm font-medium">{errorMessage}</p>
                  </motion.div>
                )}
              </motion.div>
            )}

            {/* 2. ANALYZING SPINNER */}
            {step === "analyzing" && (
              <motion.div key="analyzing" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="flex flex-col items-center justify-center py-16 text-center">
                <Loader2 size={64} className="text-indigo-400 animate-spin mb-6" />
                <h3 className="text-2xl font-bold text-white mb-2">Trwa analiza i wykrywanie...</h3>
                <p className="text-slate-400">Wykonujemy system OCR i szukamy tytułów sekcji.</p>
              </motion.div>
            )}

            {/* 3. REVIEW WIZARD */}
            {step === "review" && (
              <motion.div key="review" initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0 }} className="flex flex-col gap-6">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-slate-900/40 p-5 rounded-2xl border border-slate-700/50">
                  <div>
                    <h3 className="text-xl font-bold text-white flex items-center gap-2">
                      <Edit3 size={20} className="text-indigo-400" />
                      Zweryfikuj Podział
                    </h3>
                    <p className="text-sm text-slate-400 mt-1">Dokument posiada {totalPages} stron(y). Dostosuj nazwy i granice.</p>
                  </div>
                  <button onClick={addSection} className="flex items-center justify-center gap-2 px-4 py-2 bg-slate-800 hover:bg-slate-700 border border-slate-600 text-white text-sm font-medium rounded-lg transition-all">
                    <Plus size={16} /> Dodaj Sekcję
                  </button>
                </div>

                <div className="space-y-3 max-h-[50vh] overflow-y-auto pr-2 custom-scrollbar">
                  {sections.length === 0 && <p className="text-slate-500 text-center py-4">Brak dodanych sekcji. Użyj przycisku wyżej by zacząć cięcie od zera.</p>}

                  <Reorder.Group axis="y" values={sections} onReorder={setSections} className="space-y-3">
                    {sections.map((sec, idx) => (
                      <Reorder.Item
                        key={sec.id}
                        value={sec}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="group flex flex-col md:flex-row items-center gap-4 bg-slate-800/80 hover:bg-slate-800 p-4 rounded-xl border border-slate-700 transition-colors cursor-grab active:cursor-grabbing"
                      >
                        <div className="w-full md:w-1/2">
                          <label className="text-xs uppercase text-slate-500 font-semibold mb-1 block text-indigo-200">⇕ Przeciągnij by zmienić kolejność</label>
                          <input
                            type="text"
                            value={sec.title}
                            onChange={(e) => updateSection(sec.id, "title", e.target.value)}
                            onFocus={(e) => e.target.select()}
                            onPointerDown={(e) => e.stopPropagation()}
                            className="w-full bg-slate-900 border border-slate-600 rounded-lg px-3 py-2 text-white focus:outline-none focus:ring-1 focus:ring-indigo-500 transition-all font-medium cursor-text"
                            placeholder="Np. Umowa Cesji"
                          />
                        </div>

                        <div className="flex gap-4 w-full md:w-auto">
                          <div className="w-1/2 md:w-24">
                            <label className="text-xs uppercase text-slate-500 font-semibold mb-1 block">Od Strony</label>
                            <input
                              type="number"
                              min={1} max={totalPages}
                              value={sec.startPage}
                              onChange={(e) => updateSection(sec.id, "startPage", e.target.value === "" ? "" : parseInt(e.target.value))}
                              onFocus={(e) => e.target.select()}
                              onPointerDown={(e) => e.stopPropagation()}
                              className="w-full bg-slate-900 border border-slate-600 rounded-lg px-3 py-2 text-white focus:outline-none text-center cursor-text transition-all focus:ring-2 focus:ring-indigo-500"
                            />
                          </div>
                          <div className="w-1/2 md:w-24">
                            <label className="text-xs uppercase text-slate-500 font-semibold mb-1 block">Do Strony</label>
                            <input
                              type="number"
                              min={1} max={totalPages}
                              value={sec.endPage}
                              onChange={(e) => updateSection(sec.id, "endPage", e.target.value === "" ? "" : parseInt(e.target.value))}
                              onFocus={(e) => e.target.select()}
                              onPointerDown={(e) => e.stopPropagation()}
                              className="w-full bg-slate-900 border border-slate-600 rounded-lg px-3 py-2 text-white focus:outline-none text-center cursor-text transition-all focus:ring-2 focus:ring-indigo-500"
                            />
                          </div>
                        </div>

                        <button
                          onClick={() => removeSection(sec.id)}
                          onPointerDown={(e) => e.stopPropagation()}
                          className="p-2 md:mt-5 text-slate-500 hover:text-red-400 hover:bg-red-500/10 rounded-lg transition-colors shrink-0 z-10"
                          title="Usuń sekcję"
                        >
                          <Trash2 size={20} />
                        </button>
                      </Reorder.Item>
                    ))}
                  </Reorder.Group>
                </div>

                <div className="flex justify-end pt-4 border-t border-slate-700/50 gap-4 mt-2">
                  <button onClick={reset} className="px-5 py-2.5 rounded-xl text-slate-400 hover:text-white transition-colors">
                    Anuluj
                  </button>
                  <button onClick={startSplit} className="px-6 py-2.5 bg-indigo-500 hover:bg-indigo-400 text-white font-semibold rounded-xl shadow-lg shadow-indigo-500/25 transition-all w-full sm:w-auto">
                    Zatwierdź i Podziel Pliki
                  </button>
                </div>
              </motion.div>
            )}

            {/* 4. SPLITTING SPINNER */}
            {step === "splitting" && (
              <motion.div key="splitting" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="flex flex-col items-center justify-center py-16 text-center">
                <Loader2 size={64} className="text-indigo-400 animate-spin mb-6" />
                <h3 className="text-2xl font-bold text-white mb-2">Wycinanie Sekcji...</h3>
                <p className="text-slate-400">Przetwarzanie i pakowanie do formatu ZIP.</p>
              </motion.div>
            )}

            {/* 5. DONE */}
            {step === "done" && (
              <motion.div key="done" initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} className="flex flex-col items-center justify-center py-12 text-center">
                <div className="mb-6 p-4 bg-emerald-500/20 rounded-full">
                  <CheckCircle2 size={64} className="text-emerald-400" />
                </div>
                <h3 className="text-2xl font-bold text-white mb-2">Cięcie Zakończone!</h3>
                <p className="text-slate-400 mb-8 max-w-md">Dokumenty zostały wycięte z plików bazowych według Twoich ram czasowych i są gotowe do pobrania.</p>

                <div className="flex gap-4">
                  <a href={downloadUrl} download="Podzielone_Dokumenty.zip" className="flex items-center gap-2 px-6 py-3 bg-emerald-500 hover:bg-emerald-400 text-white font-semibold rounded-xl shadow-lg shadow-emerald-500/25 transition-all hover:-translate-y-0.5">
                    <Download size={20} /> Pobierz ZIP
                  </a>
                  <button onClick={reset} className="px-6 py-3 bg-slate-800 hover:bg-slate-700 text-white font-medium rounded-xl transition-all">
                    Nowy Plik
                  </button>
                </div>
              </motion.div>
            )}

          </AnimatePresence>
        </motion.div>
      </div>

      <div className="absolute bottom-4 left-0 w-full text-center text-xs text-slate-500/50 pointer-events-none font-medium tracking-wide">
        &copy; {new Date().getFullYear()} Artur Gilowski all rights reserved
      </div>

      <style dangerouslySetInnerHTML={{
        __html: `
        .custom-scrollbar::-webkit-scrollbar { width: 6px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #475569; border-radius: 4px; }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #64748b; }
      `}} />
    </main>
  );
}

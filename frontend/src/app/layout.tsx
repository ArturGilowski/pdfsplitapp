import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

const inter = Inter({ subsets: ['latin', 'latin-ext'] });

export const metadata: Metadata = {
  title: 'PDF Doc Splitter - AI Powered',
  description: 'Inteligentne dzielenie plików PDF na podstawie struktury dokumentu i OCR.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="pl">
      <body className={`${inter.className} bg-slate-900 text-slate-100 min-h-screen antialiased selection:bg-indigo-500/30`}>
        {children}
      </body>
    </html>
  );
}

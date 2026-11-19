import { Injectable } from '@nestjs/common';
// Must be imported before 'pdf-parse'. It loads @napi-rs/canvas and sets the
// DOMMatrix/ImageData/Path2D globals pdfjs needs. Without it, serverless
// bundlers (Vercel) drop the canvas package and the app crashes on startup
// with "DOMMatrix is not defined".
import { CanvasFactory } from 'pdf-parse/worker';
import { PDFParse } from 'pdf-parse';

@Injectable()
export class ResumeParserService {
  async extractText(buffer: Buffer): Promise<string> {
    const parser = new PDFParse({ data: buffer, CanvasFactory });

    try {
      const result = await parser.getText();
      return result.text;
    } finally {
      await parser.destroy();
    }
  }
}
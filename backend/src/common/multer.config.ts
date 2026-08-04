import { memoryStorage } from 'multer';
import { extname } from 'path';
import { randomUUID } from 'crypto';

export const multerConfig = {
  storage: memoryStorage(),

  fileFilter: (_, file, callback) => {
    const allowed = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    ];

    callback(
      null,
      allowed.includes(file.mimetype),
    );
  },
};

export function generateResumeFileName(originalName: string) {
  return `${randomUUID()}${extname(originalName)}`;
}
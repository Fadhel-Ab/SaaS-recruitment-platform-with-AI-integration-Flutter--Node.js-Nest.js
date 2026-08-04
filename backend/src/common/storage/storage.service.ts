import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

const RESUME_SIGNED_URL_TTL_SECONDS = 600;

@Injectable()
export class StorageService {
  private readonly logger = new Logger(StorageService.name);
  private readonly client: SupabaseClient;
  private readonly bucket: string;

  constructor(private config: ConfigService) {
    const url = this.config.get<string>('SUPABASE_URL');
    const serviceRoleKey = this.config.get<string>(
      'SUPABASE_SERVICE_ROLE_KEY',
    );
    this.bucket = this.config.get<string>('SUPABASE_RESUME_BUCKET', 'resumes');

    if (!url || !serviceRoleKey) {
      throw new Error(
        'SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set to enable resume storage.',
      );
    }

    this.client = createClient(url, serviceRoleKey);
  }

  private resumePath(fileName: string) {
    return `cvs/${fileName}`;
  }

  async uploadResume(fileName: string, buffer: Buffer, contentType?: string) {
    const { error } = await this.client.storage
      .from(this.bucket)
      .upload(this.resumePath(fileName), buffer, {
        contentType,
        upsert: true,
      });

    if (error) {
      this.logger.error(`Failed to upload resume ${fileName}: ${error.message}`);
      throw error;
    }
  }

  async downloadResume(fileName: string): Promise<Buffer> {
    const { data, error } = await this.client.storage
      .from(this.bucket)
      .download(this.resumePath(fileName));

    if (error || !data) {
      throw error ?? new Error(`Resume ${fileName} not found`);
    }

    return Buffer.from(await data.arrayBuffer());
  }

  /** A time-limited signed URL — resumes are private candidate PII, never a public link. */
  async getResumeUrl(fileName: string): Promise<string | null> {
    const { data, error } = await this.client.storage
      .from(this.bucket)
      .createSignedUrl(this.resumePath(fileName), RESUME_SIGNED_URL_TTL_SECONDS);

    if (error || !data) {
      this.logger.warn(
        `Could not create signed URL for resume ${fileName}: ${error?.message}`,
      );
      return null;
    }

    return data.signedUrl;
  }
}

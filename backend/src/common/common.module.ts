import { Module } from '@nestjs/common';
import { StorageModule } from './storage/storage.module.js';

@Module({
  imports: [StorageModule]
})
export class CommonModule {}

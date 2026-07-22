import { Test, TestingModule } from '@nestjs/testing';
import { AIProviderService } from './ai.provider.service.js';

describe('AiProviderService', () => {
  let service: AIProviderService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AIProviderService],
    }).compile();

    service = module.get<AIProviderService>(AIProviderService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});

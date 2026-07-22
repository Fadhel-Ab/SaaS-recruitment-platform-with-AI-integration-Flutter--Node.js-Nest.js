import { Test, TestingModule } from '@nestjs/testing';
import { AiInterviewController } from './ai-interview.controller.js';

describe('AiInterviewController', () => {
  let controller: AiInterviewController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AiInterviewController],
    }).compile();

    controller = module.get<AiInterviewController>(AiInterviewController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});

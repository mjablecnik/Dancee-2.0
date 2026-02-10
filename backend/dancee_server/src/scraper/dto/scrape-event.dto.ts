import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class ScrapeEventDto {
  @IsString()
  @IsNotEmpty()
  eventId: string;
}

export class ScrapeEventListDto {
  @IsString()
  @IsNotEmpty()
  pageId: string;

  @IsOptional()
  @IsString()
  eventType?: 'upcoming' | 'past';
}

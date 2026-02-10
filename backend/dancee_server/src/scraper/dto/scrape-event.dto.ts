import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ScrapeEventDto {
  @ApiProperty({
    description: 'Facebook event ID or full event URL',
    example: '1987385505448084',
    type: String,
  })
  @IsString()
  @IsNotEmpty()
  eventId: string;
}

export class ScrapeEventListDto {
  @ApiProperty({
    description: 'Facebook page, group, or profile ID or full URL',
    example: '123456789',
    type: String,
  })
  @IsString()
  @IsNotEmpty()
  pageId: string;

  @ApiProperty({
    description: 'Filter events by type (upcoming or past)',
    enum: ['upcoming', 'past'],
    required: false,
    example: 'upcoming',
  })
  @IsOptional()
  @IsString()
  eventType?: 'upcoming' | 'past';
}

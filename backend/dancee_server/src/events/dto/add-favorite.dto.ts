import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class AddFavoriteDto {
  @ApiProperty({
    description: 'User identifier',
    example: 'user123',
  })
  @IsString()
  @IsNotEmpty()
  userId: string;

  @ApiProperty({
    description: 'Event identifier to add to favorites',
    example: 'event-001',
  })
  @IsString()
  @IsNotEmpty()
  eventId: string;
}

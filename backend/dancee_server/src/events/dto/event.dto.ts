import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class AddressDto {
  @ApiProperty({ description: 'Street address', example: 'Vodičkova 36' })
  street: string;

  @ApiProperty({ description: 'City name', example: 'Prague' })
  city: string;

  @ApiProperty({ description: 'Postal code', example: '110 00' })
  postalCode: string;

  @ApiProperty({ description: 'Country name', example: 'Czech Republic' })
  country: string;
}

export class VenueDto {
  @ApiProperty({ description: 'Venue name', example: 'Lucerna Music Bar' })
  name: string;

  @ApiProperty({ description: 'Venue address', type: AddressDto })
  address: AddressDto;

  @ApiPropertyOptional({ description: 'Venue description', example: 'Historic music venue in the heart of Prague' })
  description?: string;

  @ApiPropertyOptional({ description: 'Latitude coordinate', example: 50.0813 })
  latitude?: number;

  @ApiPropertyOptional({ description: 'Longitude coordinate', example: 14.4258 })
  longitude?: number;
}

export class EventInfoDto {
  @ApiProperty({ description: 'Info type', enum: ['price', 'url', 'text'], example: 'price' })
  type: string;

  @ApiProperty({ description: 'Info key/label', example: 'Entry Fee' })
  key: string;

  @ApiProperty({ description: 'Info value', example: '200 Kč' })
  value: string;
}

export class EventPartDto {
  @ApiProperty({ description: 'Part name', example: 'Social Dancing' })
  name: string;

  @ApiPropertyOptional({ description: 'Part description', example: 'Open social dancing with live band' })
  description?: string;

  @ApiProperty({ description: 'Part type', enum: ['party', 'workshop', 'openLesson', 'course'], example: 'party' })
  type: string;

  @ApiProperty({ description: 'Start time (ISO 8601)', example: '2024-02-15T20:00:00Z' })
  startTime: string;

  @ApiPropertyOptional({ description: 'End time (ISO 8601)', example: '2024-02-16T02:00:00Z' })
  endTime?: string;

  @ApiPropertyOptional({ description: 'List of DJs', type: [String], example: ['DJ Carlos', 'DJ Maria'] })
  djs?: string[];

  @ApiPropertyOptional({ description: 'List of lectors/instructors', type: [String], example: ['Carlos & Maria'] })
  lectors?: string[];
}

export class EventDto {
  @ApiProperty({ description: 'Unique event identifier', example: 'event-001' })
  id: string;

  @ApiProperty({ description: 'Event title', example: 'Prague Salsa Night' })
  title: string;

  @ApiPropertyOptional({ description: 'Event description', example: 'Join us for an amazing night of Salsa dancing!' })
  description?: string;

  @ApiProperty({ description: 'Event organizer', example: 'Prague Salsa Club' })
  organizer: string;

  @ApiProperty({ description: 'Event venue', type: VenueDto })
  venue: VenueDto;

  @ApiProperty({ description: 'Event start time (ISO 8601)', example: '2024-02-15T20:00:00Z' })
  startTime: string;

  @ApiPropertyOptional({ description: 'Event end time (ISO 8601)', example: '2024-02-16T02:00:00Z' })
  endTime?: string;

  @ApiPropertyOptional({ description: 'Event duration in milliseconds', example: 21600000 })
  duration?: number;

  @ApiProperty({ description: 'List of dance styles', type: [String], example: ['Salsa', 'Bachata'] })
  dances: string[];

  @ApiPropertyOptional({ description: 'Additional event information', type: [EventInfoDto] })
  info?: EventInfoDto[];

  @ApiPropertyOptional({ description: 'Event parts/segments', type: [EventPartDto] })
  parts?: EventPartDto[];

  @ApiPropertyOptional({ description: 'Whether event is marked as favorite', example: false })
  isFavorite?: boolean;
}

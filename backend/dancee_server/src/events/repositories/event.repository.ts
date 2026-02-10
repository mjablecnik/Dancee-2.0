import { Injectable } from '@nestjs/common';
import { EventDto } from '../dto/event.dto';

/**
 * Repository for managing dance events using in-memory storage.
 * This is a direct port from the Dart dancee_event_service.
 */
@Injectable()
export class EventRepository {
  private events: EventDto[] = [];

  constructor() {
    this.initializeSampleData();
  }

  async getAllEvents(): Promise<EventDto[]> {
    return [...this.events];
  }

  async eventExists(eventId: string): Promise<boolean> {
    return this.events.some(event => event.id === eventId);
  }

  async getEventById(eventId: string): Promise<EventDto | null> {
    return this.events.find(event => event.id === eventId) || null;
  }

  private initializeSampleData(): void {
    const now = new Date();
    
    this.events = [
      {
        id: 'event-001',
        title: 'Prague Salsa Night',
        description: 'Join us for an amazing night of Salsa dancing! Live band performance and social dancing until late.',
        organizer: 'Prague Salsa Club',
        venue: {
          name: 'Lucerna Music Bar',
          address: {
            street: 'Vodičkova 36',
            city: 'Prague',
            postalCode: '110 00',
            country: 'Czech Republic',
          },
          description: 'Historic music venue in the heart of Prague',
          latitude: 50.0813,
          longitude: 14.4258,
        },
        startTime: new Date(now.getTime() + 5 * 24 * 60 * 60 * 1000 + 20 * 60 * 60 * 1000).toISOString(),
        endTime: new Date(now.getTime() + 6 * 24 * 60 * 60 * 1000 + 2 * 60 * 60 * 1000).toISOString(),
        duration: 6 * 60 * 60 * 1000,
        dances: ['Salsa', 'Bachata'],
        info: [
          { type: 'price', key: 'Entry Fee', value: '200 Kč' },
          { type: 'url', key: 'Facebook Event', value: 'https://facebook.com/events/salsa-night' },
        ],
        parts: [
          {
            name: 'Social Dancing',
            description: 'Open social dancing with live band',
            type: 'party',
            startTime: new Date(now.getTime() + 5 * 24 * 60 * 60 * 1000 + 20 * 60 * 60 * 1000).toISOString(),
            endTime: new Date(now.getTime() + 6 * 24 * 60 * 60 * 1000 + 2 * 60 * 60 * 1000).toISOString(),
            djs: ['DJ Carlos', 'DJ Maria'],
          },
        ],
      },
      {
        id: 'event-002',
        title: 'Bachata Sensual Workshop & Party',
        description: 'Learn Bachata Sensual with international instructors followed by a social party.',
        organizer: 'Bachata Prague',
        venue: {
          name: 'Dance Studio XL',
          address: {
            street: 'Vinohradská 48',
            city: 'Prague',
            postalCode: '120 00',
            country: 'Czech Republic',
          },
          description: 'Modern dance studio with professional floor',
          latitude: 50.0755,
          longitude: 14.4378,
        },
        startTime: new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000 + 19.5 * 60 * 60 * 1000).toISOString(),
        endTime: new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000 + 23.5 * 60 * 60 * 1000).toISOString(),
        duration: 4 * 60 * 60 * 1000,
        dances: ['Bachata'],
        info: [
          { type: 'price', key: 'Workshop + Party', value: '350 Kč' },
          { type: 'price', key: 'Party Only', value: '150 Kč' },
          { type: 'text', key: 'Level', value: 'Intermediate' },
        ],
        parts: [
          {
            name: 'Bachata Sensual Workshop',
            description: 'Intermediate level workshop focusing on body movement',
            type: 'workshop',
            startTime: new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000 + 19.5 * 60 * 60 * 1000).toISOString(),
            endTime: new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000 + 21 * 60 * 60 * 1000).toISOString(),
            lectors: ['Carlos & Maria', 'David & Sofia'],
          },
          {
            name: 'Social Party',
            description: 'Social dancing with the best Bachata music',
            type: 'party',
            startTime: new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000 + 21 * 60 * 60 * 1000).toISOString(),
            endTime: new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000 + 23.5 * 60 * 60 * 1000).toISOString(),
            djs: ['DJ Romeo'],
          },
        ],
      },
      {
        id: 'event-003',
        title: 'Prague Kizomba Festival 2024',
        description: 'Three-day Kizomba festival with international instructors, workshops, and parties.',
        organizer: 'Kizomba Czech',
        venue: {
          name: 'Hotel Olympik Congress',
          address: {
            street: 'Sokolovská 138',
            city: 'Prague',
            postalCode: '186 00',
            country: 'Czech Republic',
          },
          description: 'Large conference hotel with multiple dance halls',
          latitude: 50.1008,
          longitude: 14.4547,
        },
        startTime: new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000).toISOString(),
        endTime: new Date(now.getTime() + 17 * 24 * 60 * 60 * 1000).toISOString(),
        duration: 3 * 24 * 60 * 60 * 1000,
        dances: ['Kizomba', 'Urban Kiz', 'Semba'],
        info: [
          { type: 'price', key: 'Full Pass', value: '2500 Kč' },
          { type: 'price', key: 'Party Pass', value: '1200 Kč' },
          { type: 'url', key: 'Registration', value: 'https://kizombafestival.cz' },
        ],
        parts: [
          {
            name: 'Friday Night Party',
            type: 'party',
            startTime: new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000 + 21 * 60 * 60 * 1000).toISOString(),
            endTime: new Date(now.getTime() + 15 * 24 * 60 * 60 * 1000 + 3 * 60 * 60 * 1000).toISOString(),
            djs: ['DJ Mika', 'DJ Zé'],
          },
        ],
      },
      {
        id: 'event-004',
        title: 'Swing Dance Open Lesson',
        description: 'Free open lesson for beginners! Learn the basics of Lindy Hop and Charleston.',
        organizer: 'Prague Swing Society',
        venue: {
          name: 'Café V lese',
          address: {
            street: 'Krymská 12',
            city: 'Prague',
            postalCode: '101 00',
            country: 'Czech Republic',
          },
          description: 'Cozy café with dance floor',
          latitude: 50.0719,
          longitude: 14.4503,
        },
        startTime: new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000 + 18 * 60 * 60 * 1000).toISOString(),
        endTime: new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000 + 20 * 60 * 60 * 1000).toISOString(),
        duration: 2 * 60 * 60 * 1000,
        dances: ['Lindy Hop', 'Charleston'],
        info: [
          { type: 'price', key: 'Entry', value: 'Free' },
          { type: 'text', key: 'Level', value: 'Beginners welcome' },
        ],
        parts: [
          {
            name: 'Open Lesson',
            description: 'Introduction to Swing dancing',
            type: 'openLesson',
            startTime: new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000 + 18 * 60 * 60 * 1000).toISOString(),
            endTime: new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000 + 20 * 60 * 60 * 1000).toISOString(),
            lectors: ['Tom & Jerry'],
          },
        ],
      },
      {
        id: 'event-005',
        title: 'Traditional Tango Milonga',
        description: 'Traditional Argentine Tango milonga with live orchestra. Dress code: elegant.',
        organizer: 'Tango Prague',
        venue: {
          name: 'Žofín Palace',
          address: {
            street: 'Slovanský ostrov 226',
            city: 'Prague',
            postalCode: '110 00',
            country: 'Czech Republic',
          },
          description: 'Historic palace on an island in the Vltava river',
          latitude: 50.0794,
          longitude: 14.4133,
        },
        startTime: new Date(now.getTime() + 10 * 24 * 60 * 60 * 1000 + 20 * 60 * 60 * 1000).toISOString(),
        endTime: new Date(now.getTime() + 11 * 24 * 60 * 60 * 1000 + 1 * 60 * 60 * 1000).toISOString(),
        duration: 5 * 60 * 60 * 1000,
        dances: ['Argentine Tango'],
        info: [
          { type: 'price', key: 'Entry Fee', value: '300 Kč' },
          { type: 'text', key: 'Dress Code', value: 'Elegant attire required' },
        ],
        parts: [
          {
            name: 'Milonga',
            description: 'Traditional tango social dancing',
            type: 'party',
            startTime: new Date(now.getTime() + 10 * 24 * 60 * 60 * 1000 + 20 * 60 * 60 * 1000).toISOString(),
            endTime: new Date(now.getTime() + 11 * 24 * 60 * 60 * 1000 + 1 * 60 * 60 * 1000).toISOString(),
            djs: ['DJ Osvaldo'],
          },
        ],
      },
      {
        id: 'event-006',
        title: 'Brazilian Zouk Intensive Weekend',
        description: 'Intensive weekend with multiple workshops covering all levels of Brazilian Zouk.',
        organizer: 'Zouk Prague',
        venue: {
          name: 'Dance Arena',
          address: {
            street: 'Komunardů 30',
            city: 'Prague',
            postalCode: '170 00',
            country: 'Czech Republic',
          },
          description: 'Large dance studio with sprung floor',
          latitude: 50.0989,
          longitude: 14.4531,
        },
        startTime: new Date(now.getTime() + 21 * 24 * 60 * 60 * 1000 + 10 * 60 * 60 * 1000).toISOString(),
        endTime: new Date(now.getTime() + 23 * 24 * 60 * 60 * 1000 + 2 * 60 * 60 * 1000).toISOString(),
        duration: 64 * 60 * 60 * 1000,
        dances: ['Brazilian Zouk'],
        info: [
          { type: 'price', key: 'Full Weekend', value: '1800 Kč' },
          { type: 'price', key: 'Single Day', value: '700 Kč' },
          { type: 'url', key: 'Schedule', value: 'https://zoukprague.cz/intensive' },
        ],
        parts: [
          {
            name: 'Saturday Workshops',
            description: 'Full day of workshops for all levels',
            type: 'workshop',
            startTime: new Date(now.getTime() + 21 * 24 * 60 * 60 * 1000 + 10 * 60 * 60 * 1000).toISOString(),
            endTime: new Date(now.getTime() + 21 * 24 * 60 * 60 * 1000 + 18 * 60 * 60 * 1000).toISOString(),
            lectors: ['Alex & Renata', 'Bruno & Camila'],
          },
          {
            name: 'Saturday Night Party',
            type: 'party',
            startTime: new Date(now.getTime() + 21 * 24 * 60 * 60 * 1000 + 21 * 60 * 60 * 1000).toISOString(),
            endTime: new Date(now.getTime() + 22 * 24 * 60 * 60 * 1000 + 2 * 60 * 60 * 1000).toISOString(),
            djs: ['DJ Zouk Master'],
          },
        ],
      },
      {
        id: 'event-007',
        title: 'Salsa & Bachata Fusion Night',
        description: 'Mixed night with both Salsa and Bachata music. Perfect for dancers who love both styles!',
        organizer: 'Latin Dance Prague',
        venue: {
          name: 'Club Mecca',
          address: {
            street: 'U Průhonu 3',
            city: 'Prague',
            postalCode: '170 00',
            country: 'Czech Republic',
          },
          description: 'Popular nightclub with large dance floor',
          latitude: 50.1033,
          longitude: 14.4442,
        },
        startTime: new Date(now.getTime() + 2 * 24 * 60 * 60 * 1000 + 21 * 60 * 60 * 1000).toISOString(),
        endTime: new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000 + 3 * 60 * 60 * 1000).toISOString(),
        duration: 6 * 60 * 60 * 1000,
        dances: ['Salsa', 'Bachata'],
        info: [
          { type: 'price', key: 'Entry Fee', value: '150 Kč' },
          { type: 'text', key: 'Dress Code', value: 'Casual' },
        ],
        parts: [
          {
            name: 'Social Dancing',
            description: 'Mixed Salsa and Bachata music all night',
            type: 'party',
            startTime: new Date(now.getTime() + 2 * 24 * 60 * 60 * 1000 + 21 * 60 * 60 * 1000).toISOString(),
            endTime: new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000 + 3 * 60 * 60 * 1000).toISOString(),
            djs: ['DJ Latino', 'DJ Tropical'],
          },
        ],
      },
      {
        id: 'event-008',
        title: 'West Coast Swing Beginner Workshop',
        description: 'Introduction to West Coast Swing for complete beginners. No partner needed!',
        organizer: 'WCS Prague',
        venue: {
          name: 'Studio Tančírna',
          address: {
            street: 'Blanická 25',
            city: 'Prague',
            postalCode: '120 00',
            country: 'Czech Republic',
          },
          description: 'Professional dance studio in Vinohrady',
          latitude: 50.0742,
          longitude: 14.4411,
        },
        startTime: new Date(now.getTime() + 8 * 24 * 60 * 60 * 1000 + 19 * 60 * 60 * 1000).toISOString(),
        endTime: new Date(now.getTime() + 8 * 24 * 60 * 60 * 1000 + 21 * 60 * 60 * 1000).toISOString(),
        duration: 2 * 60 * 60 * 1000,
        dances: ['West Coast Swing'],
        info: [
          { type: 'price', key: 'Workshop Fee', value: '250 Kč' },
          { type: 'text', key: 'Level', value: 'Absolute beginners' },
          { type: 'text', key: 'Partner', value: 'No partner needed' },
        ],
        parts: [
          {
            name: 'Beginner Workshop',
            description: 'Learn the basics of West Coast Swing',
            type: 'workshop',
            startTime: new Date(now.getTime() + 8 * 24 * 60 * 60 * 1000 + 19 * 60 * 60 * 1000).toISOString(),
            endTime: new Date(now.getTime() + 8 * 24 * 60 * 60 * 1000 + 21 * 60 * 60 * 1000).toISOString(),
            lectors: ['Mike & Sarah'],
          },
        ],
      },
    ];
  }
}

import { Controller, Get, Query, Param, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiParam, ApiQuery, ApiResponse } from '@nestjs/swagger';
import { ScraperService } from './scraper.service';

@ApiTags('scraper')
@Controller('scraper')
export class ScraperController {
  constructor(private readonly scraperService: ScraperService) {}

  /**
   * GET /scraper
   * Get API usage information
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Get API information',
    description: 'Returns information about available endpoints and usage examples'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'API information retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string', example: 'Facebook Event Scraper API' },
        version: { type: 'string', example: '1.0.0' },
        endpoints: { type: 'object' },
        notes: { type: 'array', items: { type: 'string' } }
      }
    }
  })
  getInfo() {
    return {
      message: 'Facebook Event Scraper API',
      version: '1.0.0',
      endpoints: {
        'GET /scraper/event/:eventId': {
          description: 'Scrape a single Facebook event',
          parameters: {
            eventId: 'Facebook event ID or full URL (must be public)',
          },
          examples: [
            'GET /scraper/event/1987385505448084',
            'GET /scraper/event/https://www.facebook.com/events/1987385505448084',
          ],
        },
        'GET /scraper/events': {
          description: 'Scrape a list of events from a page/group/profile',
          parameters: {
            pageId: 'Facebook page/group/profile ID or URL (required)',
            eventType: 'Filter by "upcoming" or "past" (optional)',
          },
          examples: [
            'GET /scraper/events?pageId=123456789&eventType=upcoming',
            'GET /scraper/events?pageId=https://www.facebook.com/yourpage',
          ],
        },
      },
      notes: [
        'Only PUBLIC Facebook events can be scraped',
        'Events must be active and accessible',
        'Rate limiting may apply',
        'Use at your own risk - Facebook ToS prohibit automated scraping',
      ],
    };
  }

  /**
   * GET /scraper/event/:eventId
   * Scrape a single Facebook event by ID or URL
   * 
   * @param eventId - Facebook event ID (e.g., "115982989234742") or full URL
   * @returns Full event data including location, photos, hosts, etc.
   * 
   * Example: GET /scraper/event/115982989234742
   */
  @Get('event/:eventId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Scrape a single Facebook event',
    description: 'Retrieves detailed information about a specific Facebook event by ID or URL. Only works with public events.'
  })
  @ApiParam({ 
    name: 'eventId', 
    description: 'Facebook event ID (e.g., "115982989234742") or full event URL',
    example: '1987385505448084',
    type: String
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Event data retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', example: '1987385505448084' },
        name: { type: 'string', example: 'Summer Dance Festival 2024' },
        description: { type: 'string' },
        startTimestamp: { type: 'number' },
        endTimestamp: { type: 'number' },
        location: { 
          type: 'object',
          properties: {
            name: { type: 'string' },
            address: { type: 'string' },
            coordinates: { 
              type: 'object',
              properties: {
                latitude: { type: 'number' },
                longitude: { type: 'number' }
              }
            }
          }
        },
        photo: { type: 'string' },
        url: { type: 'string' }
      }
    }
  })
  @ApiResponse({ 
    status: 400, 
    description: 'Invalid event ID or URL' 
  })
  @ApiResponse({ 
    status: 404, 
    description: 'Event not found or not public' 
  })
  async scrapeEvent(@Param('eventId') eventId: string) {
    return this.scraperService.scrapeEvent(eventId);
  }

  /**
   * GET /scraper/events?pageId=xxx&eventType=upcoming
   * Scrape a list of events from a Facebook page, group, or profile
   * 
   * @param pageId - Facebook page/group/profile ID or URL (required)
   * @param eventType - Filter by 'upcoming' or 'past' events (optional)
   * @returns Array of event summaries
   * 
   * Example: GET /scraper/events?pageId=123456789&eventType=upcoming
   */
  @Get('events')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Scrape events from a Facebook page/group',
    description: 'Retrieves a list of events from a Facebook page, group, or profile. Can filter by upcoming or past events.'
  })
  @ApiQuery({ 
    name: 'pageId', 
    description: 'Facebook page/group/profile ID or full URL',
    example: '123456789',
    required: true,
    type: String
  })
  @ApiQuery({ 
    name: 'eventType', 
    description: 'Filter events by type',
    enum: ['upcoming', 'past'],
    required: false,
    type: String
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Event list retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', example: '1987385505448084' },
          name: { type: 'string', example: 'Summer Dance Festival 2024' },
          startTimestamp: { type: 'number' },
          location: { type: 'string' },
          photo: { type: 'string' },
          url: { type: 'string' }
        }
      }
    }
  })
  @ApiResponse({ 
    status: 400, 
    description: 'Missing or invalid pageId parameter' 
  })
  @ApiResponse({ 
    status: 404, 
    description: 'Page not found or has no public events' 
  })
  async scrapeEventList(
    @Query('pageId') pageId: string,
    @Query('eventType') eventType?: 'upcoming' | 'past',
  ) {
    if (!pageId) {
      throw new Error('pageId query parameter is required');
    }
    return this.scraperService.scrapeEventList(pageId, eventType);
  }
}

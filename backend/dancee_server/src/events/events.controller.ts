import {
  Controller,
  Get,
  Post,
  Delete,
  Query,
  Param,
  Body,
  HttpCode,
  HttpStatus,
  BadRequestException,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiQuery,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
import { EventsService } from './events.service';
import { EventDto } from './dto/event.dto';
import { AddFavoriteDto } from './dto/add-favorite.dto';

/**
 * HTTP controller for dance event endpoints.
 * This is a direct port from the Dart dancee_event_service.
 */
@ApiTags('events')
@Controller('events')
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

  @Get('list')
  @ApiOperation({
    summary: 'List all dance events',
    description:
      'Retrieves all available dance events. Optionally accepts userId query parameter to mark favorite events.',
  })
  @ApiQuery({
    name: 'userId',
    required: false,
    description: 'User identifier to mark favorite events',
    example: 'user123',
  })
  @ApiResponse({
    status: 200,
    description: 'List of events successfully retrieved',
    type: [EventDto],
  })
  @ApiResponse({
    status: 500,
    description: 'Internal server error',
  })
  async listEvents(@Query('userId') userId?: string): Promise<EventDto[]> {
    return this.eventsService.getAllEvents(userId);
  }

  @Get('favorites')
  @ApiOperation({
    summary: 'List user favorite events',
    description:
      'Retrieves all favorite events for a specific user. Requires userId query parameter.',
  })
  @ApiQuery({
    name: 'userId',
    required: true,
    description: 'User identifier',
    example: 'user123',
  })
  @ApiResponse({
    status: 200,
    description: 'List of favorite events successfully retrieved',
    type: [EventDto],
  })
  @ApiResponse({
    status: 400,
    description: 'userId query parameter is required',
  })
  @ApiResponse({
    status: 500,
    description: 'Internal server error',
  })
  async listFavorites(@Query('userId') userId?: string): Promise<EventDto[]> {
    if (!userId) {
      throw new BadRequestException('userId query parameter is required');
    }
    return this.eventsService.getFavorites(userId);
  }

  @Post('favorites')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Add event to favorites',
    description:
      'Adds an event to user favorites. Requires userId and eventId in request body.',
  })
  @ApiBody({
    type: AddFavoriteDto,
    description: 'User and event identifiers',
  })
  @ApiResponse({
    status: 201,
    description: 'Favorite added successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string', example: 'Favorite added successfully' },
        userId: { type: 'string', example: 'user123' },
        eventId: { type: 'string', example: 'event-001' },
      },
    },
  })
  @ApiResponse({
    status: 400,
    description: 'userId and eventId are required',
  })
  @ApiResponse({
    status: 404,
    description: 'Event not found',
  })
  @ApiResponse({
    status: 500,
    description: 'Internal server error',
  })
  async addFavorite(@Body() addFavoriteDto: AddFavoriteDto) {
    const { userId, eventId } = addFavoriteDto;

    await this.eventsService.addFavorite(userId, eventId);

    return {
      message: 'Favorite added successfully',
      userId,
      eventId,
    };
  }

  @Delete('favorites/:eventId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Remove event from favorites',
    description:
      'Removes an event from user favorites. Requires userId query parameter and eventId path parameter.',
  })
  @ApiParam({
    name: 'eventId',
    description: 'Event identifier to remove from favorites',
    example: 'event-001',
  })
  @ApiQuery({
    name: 'userId',
    required: true,
    description: 'User identifier',
    example: 'user123',
  })
  @ApiResponse({
    status: 204,
    description: 'Favorite removed successfully',
  })
  @ApiResponse({
    status: 400,
    description: 'userId query parameter is required',
  })
  @ApiResponse({
    status: 404,
    description: 'Event not found',
  })
  @ApiResponse({
    status: 500,
    description: 'Internal server error',
  })
  async removeFavorite(
    @Param('eventId') eventId: string,
    @Query('userId') userId?: string,
  ): Promise<void> {
    if (!userId) {
      throw new BadRequestException('userId query parameter is required');
    }

    await this.eventsService.removeFavorite(userId, eventId);
  }
}

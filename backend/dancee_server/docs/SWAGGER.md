# Swagger API Documentation

## Overview

The Dancee Server now includes interactive Swagger/OpenAPI documentation for all API endpoints.

## Accessing Swagger UI

Once the server is running, you can access the Swagger documentation at:

```
http://localhost:3001/api
```

## Features

The Swagger documentation provides:

- **Interactive API Explorer**: Test endpoints directly from your browser
- **Request/Response Schemas**: See exactly what data format is expected
- **Parameter Documentation**: Detailed information about all parameters
- **Response Examples**: Sample responses for each endpoint
- **Error Codes**: Documentation of possible error responses

## Available Endpoints

### App Endpoints
- `GET /` - Health check endpoint

### Scraper Endpoints
- `GET /scraper` - Get API information and usage examples
- `GET /scraper/event/:eventId` - Scrape a single Facebook event
- `GET /scraper/events` - Scrape events from a Facebook page/group

## Using Swagger UI

1. **Start the server**:
   ```bash
   npm run start:dev
   ```

2. **Open your browser** and navigate to:
   ```
   http://localhost:3001/api
   ```

3. **Explore endpoints**:
   - Click on any endpoint to expand it
   - Click "Try it out" to test the endpoint
   - Fill in required parameters
   - Click "Execute" to send the request
   - View the response below

## Example Usage

### Testing the Event Scraper

1. Navigate to `http://localhost:3001/api`
2. Find the `GET /scraper/event/{eventId}` endpoint
3. Click "Try it out"
4. Enter a Facebook event ID (e.g., `1987385505448084`)
5. Click "Execute"
6. View the scraped event data in the response

### Testing the Event List Scraper

1. Find the `GET /scraper/events` endpoint
2. Click "Try it out"
3. Enter a Facebook page ID in the `pageId` field
4. Optionally select `upcoming` or `past` for `eventType`
5. Click "Execute"
6. View the list of events in the response

## OpenAPI Specification

The OpenAPI/Swagger specification is automatically generated and can be accessed at:

```
http://localhost:3001/api-json
```

This JSON file can be imported into tools like:
- Postman
- Insomnia
- API testing frameworks
- Code generators

## Development

### Adding Documentation to New Endpoints

When creating new endpoints, use these decorators:

```typescript
import { ApiTags, ApiOperation, ApiParam, ApiQuery, ApiResponse } from '@nestjs/swagger';

@ApiTags('your-tag')
@Controller('your-controller')
export class YourController {
  
  @Get(':id')
  @ApiOperation({ 
    summary: 'Short description',
    description: 'Detailed description'
  })
  @ApiParam({ 
    name: 'id', 
    description: 'Parameter description',
    example: '123'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Success response description'
  })
  async yourMethod(@Param('id') id: string) {
    // Your code
  }
}
```

### Documenting DTOs

Add `@ApiProperty()` decorators to your DTO classes:

```typescript
import { ApiProperty } from '@nestjs/swagger';

export class YourDto {
  @ApiProperty({
    description: 'Field description',
    example: 'example value',
    type: String
  })
  yourField: string;
}
```

## Configuration

Swagger configuration is located in `src/main.ts`:

```typescript
const config = new DocumentBuilder()
  .setTitle('Dancee Server API')
  .setDescription('Facebook Event Scraper API for Dancee App')
  .setVersion('1.0.0')
  .addTag('scraper', 'Facebook event scraping endpoints')
  .addTag('app', 'Application health and info endpoints')
  .build();
```

You can customize:
- Title and description
- Version number
- Tags for grouping endpoints
- Authentication schemes (when needed)
- Contact information
- License information

## Notes

- Swagger UI is available in all environments (development, staging, production)
- Consider adding authentication to Swagger UI in production environments
- The documentation is automatically updated when you modify decorators
- All changes are reflected immediately in development mode with hot reload

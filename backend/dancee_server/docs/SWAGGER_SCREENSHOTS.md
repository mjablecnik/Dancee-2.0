# Swagger UI - What to Expect

## Accessing the Documentation

Once you start the server with `npm run start:dev`, you'll see:

```
🚀 Dancee Server is running on: http://localhost:3001
📚 Swagger documentation available at: http://localhost:3001/api
```

## What You'll See

### Main Swagger UI Page

When you navigate to `http://localhost:3001/api`, you'll see:

1. **API Title and Description**
   - "Dancee Server API"
   - "Facebook Event Scraper API for Dancee App"
   - Version: 1.0.0

2. **Grouped Endpoints by Tags**
   - **app** - Application health and info endpoints
   - **scraper** - Facebook event scraping endpoints

### Endpoint Details

Each endpoint shows:

#### GET / (Health Check)
- **Summary**: Health check
- **Description**: Returns a simple message to verify the API is running
- **Response**: String "Hello World!"

#### GET /scraper (API Info)
- **Summary**: Get API information
- **Description**: Returns information about available endpoints and usage examples
- **Response**: Object with message, version, endpoints, and notes

#### GET /scraper/event/{eventId}
- **Summary**: Scrape a single Facebook event
- **Description**: Retrieves detailed information about a specific Facebook event by ID or URL
- **Parameters**:
  - `eventId` (path, required) - Facebook event ID or URL
  - Example: "1987385505448084"
- **Responses**:
  - 200: Event data retrieved successfully (with schema)
  - 400: Invalid event ID or URL
  - 404: Event not found or not public

#### GET /scraper/events
- **Summary**: Scrape events from a Facebook page/group
- **Description**: Retrieves a list of events from a Facebook page, group, or profile
- **Parameters**:
  - `pageId` (query, required) - Facebook page/group/profile ID or URL
  - `eventType` (query, optional) - Filter by "upcoming" or "past"
- **Responses**:
  - 200: Event list retrieved successfully (with schema)
  - 400: Missing or invalid pageId parameter
  - 404: Page not found or has no public events

## Interactive Testing

### How to Test an Endpoint

1. **Click on any endpoint** to expand it
2. **Click "Try it out"** button (top right of the endpoint)
3. **Fill in the parameters**:
   - For path parameters: Enter value in the input field
   - For query parameters: Enter values in the respective fields
4. **Click "Execute"** button
5. **View the results**:
   - Request URL that was called
   - Response status code
   - Response body (JSON)
   - Response headers

### Example: Testing Event Scraper

```
1. Expand: GET /scraper/event/{eventId}
2. Click: "Try it out"
3. Enter eventId: 1987385505448084
4. Click: "Execute"
5. See response:
   - Status: 200
   - Body: { id: "1987385505448084", name: "...", ... }
```

## Response Schemas

Each endpoint shows detailed response schemas with:

- **Property names** and types
- **Example values**
- **Nested object structures**
- **Array item types**

Example for event response:
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "startTimestamp": "number",
  "endTimestamp": "number",
  "location": {
    "name": "string",
    "address": "string",
    "coordinates": {
      "latitude": "number",
      "longitude": "number"
    }
  },
  "photo": "string",
  "url": "string"
}
```

## Exporting the Specification

### JSON Format
Access the raw OpenAPI specification at:
```
http://localhost:3001/api-json
```

This can be:
- Imported into Postman
- Used with code generators
- Shared with frontend developers
- Used for API testing tools

### Using with Postman

1. Open Postman
2. Click "Import"
3. Select "Link"
4. Enter: `http://localhost:3001/api-json`
5. Click "Continue"
6. All endpoints will be imported as a collection

## Benefits for Development

### For Backend Developers
- ✅ Document APIs as you code
- ✅ Test endpoints without external tools
- ✅ Validate request/response formats
- ✅ Share API contracts easily

### For Frontend Developers
- ✅ Understand API structure
- ✅ See example requests/responses
- ✅ Test endpoints before integration
- ✅ Generate TypeScript types from schema

### For Team Collaboration
- ✅ Single source of truth for API
- ✅ Always up-to-date documentation
- ✅ Interactive testing environment
- ✅ Clear error response documentation

## Tips

1. **Keep it updated**: Add decorators when creating new endpoints
2. **Use examples**: Provide realistic example values
3. **Document errors**: Include all possible error responses
4. **Group logically**: Use tags to organize related endpoints
5. **Test regularly**: Use Swagger UI to verify your changes

## Troubleshooting

### Swagger UI not loading?
- Check that the server is running
- Verify you're accessing `http://localhost:3001/api` (not `/api/`)
- Check browser console for errors

### Endpoints not showing?
- Ensure controllers have `@ApiTags()` decorator
- Verify endpoints have `@ApiOperation()` decorator
- Restart the server in development mode

### Response schema not showing?
- Add `@ApiResponse()` decorator with schema
- Use DTOs with `@ApiProperty()` decorators
- Check that types are properly defined

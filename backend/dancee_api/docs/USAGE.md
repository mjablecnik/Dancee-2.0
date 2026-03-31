# Usage Guide - Dancee API Documentation Service

This guide provides practical examples and instructions for using the Centralized API Documentation Service to explore and test backend APIs.

## Table of Contents

- [Quick Start](#quick-start)
- [Accessing Swagger UI](#accessing-swagger-ui)
- [Switching Between Services](#switching-between-services)
- [Exploring API Endpoints](#exploring-api-endpoints)
- [Testing API Endpoints](#testing-api-endpoints)
- [Using the REST API](#using-the-rest-api)
- [Common Workflows](#common-workflows)
- [Tips and Best Practices](#tips-and-best-practices)
- [Troubleshooting](#troubleshooting)

## Quick Start

### 1. Start the Documentation Service

```bash
# Navigate to the project directory
cd backend/dancee_api

# Start the development server
task dev
```

### 2. Open Swagger UI

Open your web browser and navigate to:

```
http://localhost:3003
```

You should see the Swagger UI interface with a service selector at the top.

### 3. Select a Service

Click the service selector dropdown in the top-right corner and choose a service:
- **Dancee Events API** - Event management and favorites
- **Dancee Scraper API** - Facebook event scraping

### 4. Explore and Test

Browse the available endpoints, expand them to see details, and use the "Try it out" button to test API calls.

## Accessing Swagger UI

### Main Interface

The Swagger UI is your primary interface for exploring API documentation. Access it at:

```
http://localhost:3003
```

### Interface Components

**Service Selector (Top-Right)**
- Dropdown menu to switch between different backend services
- Shows service name and version
- Persists your selection across page reloads

**Endpoint List (Left Side)**
- Organized by tags/categories
- Color-coded by HTTP method:
  - 🟢 **GET** - Retrieve data
  - 🟡 **POST** - Create new resources
  - 🔵 **PUT** - Update existing resources
  - 🟣 **PATCH** - Partial update
  - 🔴 **DELETE** - Remove resources

**Endpoint Details (Main Area)**
- Summary and description
- Parameters (path, query, headers)
- Request body schema
- Response schemas with examples
- "Try it out" interactive testing

**Models Section (Bottom)**
- Data model schemas
- Object properties and types
- Example values

### Navigation Tips

1. **Collapse/Expand All**: Use the buttons at the top to collapse or expand all endpoints
2. **Search**: Use Ctrl+F (Cmd+F on Mac) to search for specific endpoints or terms
3. **Direct Links**: Bookmark specific endpoints by copying the URL after expanding them

## Switching Between Services

### Using the Service Selector

1. **Locate the Selector**: Look for the dropdown in the top-right corner of the Swagger UI
2. **Click to Open**: Click the dropdown to see all available services
3. **Select Service**: Click on the service you want to explore
4. **Wait for Load**: The interface will reload with the selected service's documentation

### Available Services

#### Dancee Events API (dancee-events)

**Purpose**: Event management and user favorites

**Base URLs**:
- Development: `http://localhost:8080`
- Production: `https://dancee-events.fly.dev`

**Key Endpoints**:
- `GET /events` - List all events
- `GET /events/{id}` - Get event details
- `POST /favorites` - Add event to favorites
- `GET /favorites/{userId}` - Get user's favorite events
- `DELETE /favorites/{userId}/{eventId}` - Remove from favorites

**Use Cases**:
- Browse available dance events
- Manage user favorite events
- Filter events by criteria

#### Dancee Scraper API (dancee-scraper)

**Purpose**: Facebook event data extraction

**Base URLs**:
- Development: `http://localhost:3002`
- Production: `https://dancee-scraper.fly.dev`

**Key Endpoints**:
- `GET /scraper/event?url={facebookEventUrl}` - Scrape single event
- `GET /scraper/events` - Scrape multiple events
- `GET /scraper/health` - Check scraper status

**Use Cases**:
- Extract event data from Facebook
- Batch scrape multiple events
- Validate scraper functionality

## Exploring API Endpoints

### Understanding Endpoint Information

When you expand an endpoint, you'll see:

#### 1. Summary and Description

```
GET /events
Summary: List all events
Description: Retrieves a paginated list of all dance events with optional filtering
```

#### 2. Parameters

**Path Parameters** (part of the URL):
```
GET /events/{id}
  id: string (required) - Event ID
```

**Query Parameters** (URL query string):
```
GET /events?city=Prague&limit=10
  city: string (optional) - Filter by city
  limit: integer (optional) - Number of results (default: 20)
```

**Header Parameters**:
```
Authorization: Bearer <token>
Content-Type: application/json
```

#### 3. Request Body

For POST/PUT/PATCH requests, you'll see the expected request body schema:

```json
{
  "userId": "string",
  "eventId": "string"
}
```

#### 4. Responses

Each endpoint shows possible responses:

**200 OK** - Success response with data
```json
{
  "id": "123",
  "name": "Summer Dance Party",
  "date": "2024-07-15T20:00:00Z"
}
```

**400 Bad Request** - Invalid input
```json
{
  "error": "Invalid event ID format"
}
```

**404 Not Found** - Resource not found
```json
{
  "error": "Event not found"
}
```

**500 Internal Server Error** - Server error
```json
{
  "error": "Internal server error"
}
```

### Reading Data Models

Scroll to the **Models** section at the bottom to see detailed schemas:

**Event Model**:
```
Event {
  id: string
  name: string
  description: string
  date: string (date-time)
  location: Location
  organizer: string
}
```

**Location Model**:
```
Location {
  venue: string
  address: string
  city: string
  country: string
}
```

## Testing API Endpoints

### Interactive Testing with "Try it out"

#### Step 1: Expand an Endpoint

Click on any endpoint to expand its details.

#### Step 2: Click "Try it out"

Look for the blue "Try it out" button in the top-right of the endpoint section.

#### Step 3: Fill in Parameters

**Example: GET /events with query parameters**

1. Click "Try it out"
2. Fill in optional parameters:
   - `city`: Prague
   - `limit`: 10
3. Click "Execute"

**Example: POST /favorites (add to favorites)**

1. Click "Try it out"
2. Edit the request body:
   ```json
   {
     "userId": "user123",
     "eventId": "event456"
   }
   ```
3. Click "Execute"

**Example: GET /events/{id} (get specific event)**

1. Click "Try it out"
2. Fill in path parameter:
   - `id`: 123
3. Click "Execute"

#### Step 4: View Response

After clicking "Execute", you'll see:

**Request Details**:
```
Curl command:
curl -X GET "http://localhost:8080/events?city=Prague&limit=10" -H "accept: application/json"

Request URL:
http://localhost:8080/events?city=Prague&limit=10
```

**Response**:
```
Code: 200
Response body:
{
  "events": [
    {
      "id": "123",
      "name": "Prague Dance Night",
      "city": "Prague"
    }
  ],
  "total": 1
}

Response headers:
content-type: application/json
```

### Testing Different HTTP Methods

#### GET Requests (Retrieve Data)

```
GET /events
GET /events/{id}
GET /favorites/{userId}
```

**No request body needed** - just fill in path/query parameters

#### POST Requests (Create Resources)

```
POST /favorites
```

**Requires request body**:
```json
{
  "userId": "user123",
  "eventId": "event456"
}
```

#### DELETE Requests (Remove Resources)

```
DELETE /favorites/{userId}/{eventId}
```

**Path parameters only** - no request body

### Testing with Authentication

If an endpoint requires authentication:

1. Look for the 🔒 lock icon next to the endpoint
2. Click "Authorize" button at the top of the page
3. Enter your API key or token
4. Click "Authorize"
5. Now all requests will include authentication headers

## Using the REST API

### Programmatic Access

You can access the documentation service programmatically using its REST API.

### Get Service List

**Endpoint**: `GET /api/services`

**Example**:
```bash
curl http://localhost:3003/api/services
```

**Response**:
```json
[
  {
    "id": "dancee-events",
    "name": "Dancee Events API",
    "version": "1.0.0",
    "description": "Event management and favorites API",
    "baseUrl": "http://localhost:8080",
    "specPath": "/api/spec/dancee-events"
  },
  {
    "id": "dancee-scraper",
    "name": "Dancee Scraper API",
    "version": "1.0.0",
    "description": "Facebook event scraping API",
    "baseUrl": "http://localhost:3002",
    "specPath": "/api/spec/dancee-scraper"
  }
]
```

### Get OpenAPI Specification

**Endpoint**: `GET /api/spec/:serviceId`

**Example**:
```bash
# Get dancee-events spec
curl http://localhost:3003/api/spec/dancee-events

# Get dancee-scraper spec
curl http://localhost:3003/api/spec/dancee-scraper
```

**Response**: Full OpenAPI 3.0 specification in JSON format

**Use Cases**:
- Generate API clients automatically
- Import into Postman or Insomnia
- Validate API contracts in CI/CD
- Generate documentation in other formats

### Health Check

**Endpoint**: `GET /health`

**Example**:
```bash
curl http://localhost:3003/health
```

**Response**:
```json
{
  "status": "ok",
  "services": {
    "dancee-events": "loaded",
    "dancee-scraper": "loaded"
  }
}
```

## Common Workflows

### Workflow 1: Exploring a New API

**Goal**: Understand what endpoints are available and how to use them

1. **Open Swagger UI**: Navigate to `http://localhost:3003`
2. **Select Service**: Choose the service you want to explore
3. **Browse Endpoints**: Scroll through the endpoint list
4. **Read Descriptions**: Expand endpoints to read summaries and descriptions
5. **Check Models**: Scroll to the Models section to understand data structures
6. **Test Simple Endpoint**: Try a GET endpoint with no parameters
7. **Test with Parameters**: Try endpoints with query or path parameters
8. **Review Responses**: Examine response schemas and examples

### Workflow 2: Testing an API Integration

**Goal**: Verify API behavior before integrating into your application

1. **Start Backend Service**: Ensure the backend service is running
   ```bash
   # For dancee_events
   cd backend/dancee_events
   task run
   
   # For dancee_scraper
   cd backend/dancee_scraper
   task dev
   ```

2. **Open Swagger UI**: Navigate to `http://localhost:3003`

3. **Select Service**: Choose the service you're integrating with

4. **Test Endpoints**:
   - Start with simple GET requests
   - Test with different parameter values
   - Try edge cases (empty values, invalid IDs)
   - Test error scenarios

5. **Document Results**: Note the actual responses for your integration code

6. **Copy curl Commands**: Use the generated curl commands in your tests

### Workflow 3: Debugging API Issues

**Goal**: Investigate why an API call is failing

1. **Reproduce in Swagger UI**: Try the same request in Swagger UI

2. **Check Request Format**:
   - Verify parameter names and types
   - Check request body structure
   - Ensure required fields are present

3. **Examine Response**:
   - Check HTTP status code
   - Read error message
   - Review response headers

4. **Compare with Documentation**:
   - Verify you're using the correct endpoint
   - Check parameter requirements
   - Validate request body schema

5. **Test Variations**:
   - Try with minimal parameters
   - Test with example values from docs
   - Isolate the problematic parameter

### Workflow 4: Generating API Client Code

**Goal**: Create a client library for your application

1. **Get OpenAPI Spec**:
   ```bash
   curl http://localhost:3003/api/spec/dancee-events > events-api.json
   ```

2. **Use Code Generator**:
   ```bash
   # Install OpenAPI Generator
   npm install -g @openapitools/openapi-generator-cli
   
   # Generate TypeScript client
   openapi-generator-cli generate \
     -i events-api.json \
     -g typescript-axios \
     -o ./src/api/events-client
   
   # Generate Python client
   openapi-generator-cli generate \
     -i events-api.json \
     -g python \
     -o ./api/events_client
   ```

3. **Import and Use**:
   ```typescript
   import { EventsApi } from './api/events-client';
   
   const api = new EventsApi();
   const events = await api.getEvents({ city: 'Prague' });
   ```

### Workflow 5: Importing into Postman

**Goal**: Use Postman for API testing

1. **Get OpenAPI Spec URL**:
   ```
   http://localhost:3003/api/spec/dancee-events
   ```

2. **Open Postman**

3. **Import**:
   - Click "Import" button
   - Select "Link" tab
   - Paste the spec URL
   - Click "Continue"
   - Click "Import"

4. **Use Collection**:
   - All endpoints are now in a Postman collection
   - Edit environment variables for base URL
   - Test endpoints with Postman's interface

## Tips and Best Practices

### Efficient API Exploration

1. **Start with GET Endpoints**: They're safe to test and don't modify data
2. **Use Example Values**: Copy example values from the documentation
3. **Test in Order**: Test simple endpoints before complex ones
4. **Read Error Messages**: They often explain exactly what's wrong
5. **Check Response Schemas**: Understand the data structure before integrating

### Testing Best Practices

1. **Test Happy Path First**: Verify the endpoint works with valid data
2. **Test Edge Cases**: Try boundary values, empty strings, null values
3. **Test Error Scenarios**: Intentionally send invalid data to see error handling
4. **Document Findings**: Keep notes on actual behavior vs. documented behavior
5. **Use curl Commands**: Copy generated curl commands for automated testing

### Working with Multiple Services

1. **Keep Services Running**: Start all backend services you're testing
2. **Use Separate Terminals**: Run each service in its own terminal window
3. **Check Service Health**: Verify services are running before testing
4. **Switch Services Frequently**: Compare similar endpoints across services
5. **Bookmark URLs**: Save direct links to frequently used endpoints

### Performance Tips

1. **Use Filters**: Apply query parameters to limit response size
2. **Paginate Results**: Use limit/offset parameters for large datasets
3. **Cache Responses**: The documentation service caches specs in memory
4. **Test Locally First**: Use localhost URLs before testing production

### Security Considerations

1. **Don't Use Production Data**: Test with development/staging environments
2. **Protect API Keys**: Don't share authentication tokens
3. **Use HTTPS in Production**: Always use secure connections for production APIs
4. **Validate Input**: Test with malicious input to verify validation
5. **Check CORS**: Ensure CORS is properly configured for your frontend

## Troubleshooting

### Issue: "Failed to fetch" Error

**Symptom**: Swagger UI shows "Failed to fetch" when executing requests

**Causes**:
- Backend service is not running
- Wrong base URL in OpenAPI spec
- CORS issues

**Solutions**:

1. **Verify Backend Service is Running**:
   ```bash
   # Check dancee_events
   curl http://localhost:8080/health
   
   # Check dancee_scraper
   curl http://localhost:3002/health
   ```

2. **Check Base URL**: Ensure the service URL in `.env` matches the running service

3. **Check CORS**: Verify CORS is enabled on the backend service

### Issue: 404 Not Found

**Symptom**: API returns 404 error

**Causes**:
- Wrong endpoint URL
- Missing path parameters
- Service not running

**Solutions**:

1. **Verify Endpoint Path**: Check the exact path in the documentation
2. **Check Path Parameters**: Ensure all required path parameters are filled
3. **Verify Service**: Confirm the backend service is running and accessible

### Issue: 400 Bad Request

**Symptom**: API returns 400 error with validation message

**Causes**:
- Invalid parameter format
- Missing required fields
- Wrong data type

**Solutions**:

1. **Check Parameter Types**: Ensure strings are strings, numbers are numbers
2. **Verify Required Fields**: Fill in all required parameters
3. **Match Schema**: Compare your request body with the schema
4. **Check Examples**: Use example values from the documentation

### Issue: 401 Unauthorized

**Symptom**: API returns 401 error

**Causes**:
- Missing authentication
- Invalid API key/token
- Expired token

**Solutions**:

1. **Click Authorize**: Use the Authorize button at the top
2. **Enter Valid Token**: Provide a valid API key or bearer token
3. **Check Token Format**: Ensure correct format (e.g., "Bearer <token>")

### Issue: 500 Internal Server Error

**Symptom**: API returns 500 error

**Causes**:
- Backend service error
- Database connection issue
- Unexpected input

**Solutions**:

1. **Check Backend Logs**: Look at the backend service console output
2. **Try Different Input**: Test with simpler or different values
3. **Report Bug**: If persistent, report to the development team

### Issue: Slow Response Times

**Symptom**: Requests take a long time to complete

**Causes**:
- Large dataset without pagination
- Backend service performance issue
- Network latency

**Solutions**:

1. **Use Pagination**: Add limit/offset parameters
2. **Filter Results**: Use query parameters to reduce data size
3. **Check Backend**: Verify backend service performance
4. **Test Locally**: Ensure you're testing against localhost

### Issue: CORS Error in Browser

**Symptom**: Browser console shows CORS policy error

**Causes**:
- Backend service doesn't allow origin
- Missing CORS headers
- Preflight request failing

**Solutions**:

1. **Check Backend CORS**: Verify backend service has CORS enabled
2. **Update CORS Origins**: Add your origin to allowed origins
3. **Use Proxy**: Consider using a proxy for development

### Getting Help

If you encounter issues not covered here:

1. **Check Backend Service Logs**: Look for error messages
2. **Verify Configuration**: Review `.env` file settings
3. **Test with curl**: Try the same request with curl to isolate the issue
4. **Check Health Endpoint**: Verify the documentation service is healthy
5. **Review Setup Guide**: Ensure all setup steps were completed
6. **Contact Team**: Reach out to the development team with specific error details

## Next Steps

Now that you know how to use the API documentation service:

1. **Explore All Services**: Try each available backend service
2. **Test Your Use Cases**: Verify the APIs support your requirements
3. **Generate Client Code**: Create API clients for your applications
4. **Integrate APIs**: Start building your application with the APIs
5. **Provide Feedback**: Report any documentation issues or suggestions

## Additional Resources

- [Setup Guide](./SETUP.md) - Installation and configuration
- [Project README](../README.md) - Project overview
- [Contributing Guide](./CONTRIBUTING.md) - How to add new API specs
- [OpenAPI Specification](https://swagger.io/specification/) - OpenAPI 3.0 docs
- [Swagger UI Guide](https://swagger.io/tools/swagger-ui/) - Swagger UI documentation
- [curl Documentation](https://curl.se/docs/) - curl command reference

## Feedback

Have suggestions for improving this guide? Found an error? Please let the development team know!

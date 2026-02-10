# API Usage Examples

## Testing the Scraper Endpoints

### Important Notes Before Testing

1. **Public Events Only**: The scraper only works with PUBLIC Facebook events
2. **Event Must Exist**: The event must be active and accessible
3. **ID Format**: You can use either:
   - Just the event ID: `1987385505448084`
   - Full URL: `https://www.facebook.com/events/1987385505448084`

### Finding Event IDs

To find a Facebook event ID:
1. Go to the Facebook event page
2. Look at the URL: `https://www.facebook.com/events/1987385505448084/`
3. The number `1987385505448084` is the event ID

### 1. Scrape a Single Event

**Using curl with event ID:**
```bash
curl http://localhost:3001/scraper/event/1987385505448084
```

**Using curl with full URL:**
```bash
curl http://localhost:3001/scraper/event/https://www.facebook.com/events/1987385505448084
```

**Using browser:**
```
http://localhost:3001/scraper/event/1987385505448084
```

### 2. Scrape Event List from a Page

**Get upcoming events:**
```bash
curl "http://localhost:3001/scraper/events?pageId=YOUR_PAGE_ID&eventType=upcoming"
```

**Get past events:**
```bash
curl "http://localhost:3001/scraper/events?pageId=YOUR_PAGE_ID&eventType=past"
```

**Get all events (no filter):**
```bash
curl "http://localhost:3001/scraper/events?pageId=YOUR_PAGE_ID"
```

**Using browser:**
```
http://localhost:3001/scraper/events?pageId=YOUR_PAGE_ID&eventType=upcoming
```

### Common Issues

#### "Invalid Facebook event URL"
- The event ID/URL is incorrect
- The event is not public
- The event has been deleted or cancelled

#### "Failed to scrape event"
- The event requires login to view (not public)
- Facebook is blocking the request (rate limiting)
- Network connectivity issues

### Testing with Real Events

To test, you need to find a real, public Facebook event. Here's how:

1. Go to Facebook and search for public events in your area
2. Open an event page
3. Make sure it's PUBLIC (you can see it without logging in)
4. Copy the event ID from the URL
5. Use that ID in the API call

## Response Examples

### Single Event Response
```json
{
  "id": "115982989234742",
  "name": "Example Dance Event",
  "description": "Join us for an amazing night of dancing!",
  "location": {
    "id": "118309434891614",
    "name": "Dance Studio Prague",
    "address": "Václavské náměstí 1",
    "city": {
      "name": "Prague",
      "id": "111983945494775"
    },
    "countryCode": "CZ",
    "coordinates": {
      "latitude": 50.0755,
      "longitude": 14.4378
    },
    "type": "PLACE"
  },
  "photo": {
    "url": "https://www.facebook.com/photo/?fbid=595982989234742",
    "id": "595982989234742",
    "imageUri": "https://scontent.fyyc3-1.fna.fbcdn.net/v/..."
  },
  "isOnline": false,
  "url": "https://www.facebook.com/events/115982989234742",
  "startTimestamp": 1681000200,
  "endTimestamp": 1681004700,
  "formattedDate": "Saturday, April 8, 2023 at 6:30 PM – 7:45 PM UTC-06",
  "timezone": "UTC-06",
  "hosts": [
    {
      "id": "101364691376556",
      "name": "Dance Studio Prague",
      "url": "https://www.facebook.com/dance-studio-prague",
      "type": "Page"
    }
  ],
  "ticketUrl": "https://example.com/tickets",
  "usersResponded": 150
}
```

### Event List Response
```json
[
  {
    "id": "916236709985575",
    "name": "NEW YEAR EVE 2025 - Dance Party",
    "url": "https://www.facebook.com/events/916236709985575/",
    "date": "Tue, Dec 31, 2024",
    "isCanceled": false,
    "isPast": false
  },
  {
    "id": "591932410074832",
    "name": "REGGAETON NIGHT",
    "url": "https://www.facebook.com/events/591932410074832/",
    "date": "Fri, Nov 22, 2024",
    "isCanceled": false,
    "isPast": false
  },
  {
    "id": "1103230308135807",
    "name": "SALSA WORKSHOP",
    "url": "https://www.facebook.com/events/1103230308135807/",
    "date": "Sat, Nov 9, 2024",
    "isCanceled": false,
    "isPast": false
  }
]
```

## Error Handling

### Invalid Event ID
```bash
curl http://localhost:3001/scraper/event/invalid_id
```

**Response (400 Bad Request):**
```json
{
  "statusCode": 400,
  "message": "Failed to scrape event: Event not found or not public",
  "error": "Bad Request"
}
```

### Missing pageId Parameter
```bash
curl http://localhost:3001/scraper/events
```

**Response (500 Internal Server Error):**
```json
{
  "statusCode": 500,
  "message": "pageId query parameter is required"
}
```

## Integration with Frontend

### JavaScript/TypeScript Example
```typescript
// Scrape single event
async function getEvent(eventId: string) {
  const response = await fetch(`http://localhost:3001/scraper/event/${eventId}`);
  const event = await response.json();
  return event;
}

// Scrape event list
async function getEvents(pageId: string, eventType?: 'upcoming' | 'past') {
  const url = new URL('http://localhost:3001/scraper/events');
  url.searchParams.append('pageId', pageId);
  if (eventType) {
    url.searchParams.append('eventType', eventType);
  }
  
  const response = await fetch(url.toString());
  const events = await response.json();
  return events;
}

// Usage
const event = await getEvent('115982989234742');
const upcomingEvents = await getEvents('123456789', 'upcoming');
```

### Dart/Flutter Example
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// Scrape single event
Future<Map<String, dynamic>> getEvent(String eventId) async {
  final response = await http.get(
    Uri.parse('http://localhost:3001/scraper/event/$eventId'),
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load event');
  }
}

// Scrape event list
Future<List<dynamic>> getEvents(String pageId, {String? eventType}) async {
  final uri = Uri.parse('http://localhost:3001/scraper/events').replace(
    queryParameters: {
      'pageId': pageId,
      if (eventType != null) 'eventType': eventType,
    },
  );
  
  final response = await http.get(uri);
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load events');
  }
}

// Usage
final event = await getEvent('115982989234742');
final upcomingEvents = await getEvents('123456789', eventType: 'upcoming');
```

## Tips

1. **Finding Event IDs**: Event IDs can be found in Facebook event URLs:
   - `https://www.facebook.com/events/115982989234742/` → ID is `115982989234742`

2. **Finding Page IDs**: Page IDs can be found in Facebook page URLs or by using Facebook's Graph API

3. **Rate Limiting**: Be mindful of making too many requests in a short time to avoid being blocked by Facebook

4. **Public Events Only**: The scraper only works with public Facebook events that don't require authentication

5. **Multi-date Events**: Events with multiple dates will have `parentEvent` and `siblingEvents` fields populated

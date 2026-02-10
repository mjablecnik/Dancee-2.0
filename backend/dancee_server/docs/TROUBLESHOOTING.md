# Troubleshooting Guide

## Common Issues and Solutions

### 1. "Invalid Facebook event URL" Error

**Problem:** The scraper returns an error saying the Facebook event URL is invalid.

**Possible Causes:**
- The event ID is incorrect or malformed
- The event doesn't exist or has been deleted
- The event is not public (requires login to view)

**Solutions:**
1. **Verify the event is public:**
   - Open the event URL in an incognito/private browser window
   - If you can't see the event without logging in, it's not public
   - Only PUBLIC events can be scraped

2. **Check the event ID format:**
   - Correct: `1987385505448084` (just numbers)
   - Correct: `https://www.facebook.com/events/1987385505448084`
   - Incorrect: `facebook.com/events/1987385505448084` (missing https://)

3. **Test with a known public event:**
   - Search for public events in your area on Facebook
   - Find one that's clearly marked as "Public"
   - Use that event ID for testing

### 2. "Failed to scrape event" Error

**Problem:** The scraper fails to retrieve event data.

**Possible Causes:**
- Facebook is blocking the request (rate limiting)
- Network connectivity issues
- The event page structure has changed
- The event is private or restricted

**Solutions:**
1. **Wait and retry:**
   - Facebook may be rate limiting your requests
   - Wait a few minutes before trying again
   - Don't make too many requests in a short time

2. **Check your internet connection:**
   - Make sure you can access facebook.com from your server
   - Test with: `curl https://www.facebook.com`

3. **Try a different event:**
   - The specific event might have issues
   - Test with multiple different public events

### 3. Empty Event List

**Problem:** The `/scraper/events` endpoint returns an empty array.

**Possible Causes:**
- The page/group has no public events
- The page ID is incorrect
- The eventType filter excludes all events

**Solutions:**
1. **Verify the page has events:**
   - Visit the Facebook page directly
   - Check if there are any public events listed
   - Make sure you're using the correct page ID

2. **Try without filters:**
   - Remove the `eventType` parameter
   - Example: `GET /scraper/events?pageId=123456789`

3. **Check the page ID:**
   - Page IDs are numeric: `123456789`
   - Or use the full URL: `https://www.facebook.com/yourpage`

### 4. Server Won't Start

**Problem:** The server fails to start or crashes immediately.

**Solutions:**
1. **Check if port 3001 is already in use:**
   ```bash
   # Windows
   netstat -ano | findstr :3001
   
   # Kill the process if needed
   taskkill /PID <process_id> /F
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Check for TypeScript errors:**
   ```bash
   npm run build
   ```

### 5. CORS Errors (from Frontend)

**Problem:** Browser shows CORS errors when calling the API.

**Solution:**
The server already has CORS enabled. If you still see errors:

1. **Check the server is running:**
   ```bash
   curl http://localhost:3001/
   ```

2. **Verify the URL in your frontend:**
   - Should be: `http://localhost:3001`
   - Not: `https://localhost:3001` (no HTTPS in development)

3. **Check browser console for specific error messages**

### 6. Rate Limiting

**Problem:** After several requests, the scraper stops working.

**Explanation:**
Facebook may rate limit requests to prevent abuse.

**Solutions:**
1. **Reduce request frequency:**
   - Add delays between requests
   - Cache results when possible

2. **Use a proxy (advanced):**
   - The scraper supports proxy configuration
   - See the facebook-event-scraper documentation

3. **Implement caching:**
   - Store scraped events in a database
   - Only re-scrape when data is stale

## Testing Tips

### Finding Good Test Events

1. **Search for public events:**
   - Go to facebook.com/events
   - Search for events in your area
   - Look for events marked as "Public"

2. **Use event venues or organizers:**
   - Find Facebook pages of event venues
   - Dance studios, clubs, concert halls often have public events
   - Use their page ID to scrape event lists

3. **Verify event is public:**
   - Open event in incognito/private window
   - If you can see all details without logging in, it's public

### Example Public Event Sources

- Concert venues
- Dance studios
- Community centers
- Public festivals
- University event pages
- City event pages

## Debug Mode

To see more detailed logs:

1. **Check server logs:**
   - The server logs all scraping attempts
   - Look for `[ScraperService]` messages

2. **Enable debug mode (if needed):**
   ```bash
   # Set environment variable
   export DEBUG=*
   npm run start:dev
   ```

## Still Having Issues?

1. **Check the package documentation:**
   - https://github.com/francescov1/facebook-event-scraper

2. **Verify Facebook hasn't changed their page structure:**
   - The scraper depends on Facebook's HTML structure
   - Major Facebook updates may break the scraper

3. **Test with the package directly:**
   ```bash
   # In Node.js REPL
   node
   > const { scrapeFbEventFromFbid } = require('facebook-event-scraper');
   > scrapeFbEventFromFbid('YOUR_EVENT_ID').then(console.log);
   ```

## Important Reminders

⚠️ **Legal Notice:**
- Facebook's Terms of Service prohibit automated scraping
- Use this tool at your own risk
- Only scrape public data
- Respect rate limits
- Don't use for commercial purposes without proper authorization

✅ **Best Practices:**
- Only scrape public events
- Cache results to reduce requests
- Add delays between requests
- Handle errors gracefully
- Respect Facebook's robots.txt

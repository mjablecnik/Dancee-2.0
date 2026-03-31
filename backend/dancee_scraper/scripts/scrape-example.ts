/**
 * Example script: Scrape events from a Facebook page using facebook-event-scraper directly.
 *
 * Usage:
 *   npx tsx scripts/scrape-example.ts
 */

import { scrapeFbEventList } from 'facebook-event-scraper';

const PAGE_URL = 'https://www.facebook.com/praguezoukcongress';

async function main() {
  console.log(`Scraping events from: ${PAGE_URL}\n`);

  const events = await scrapeFbEventList(PAGE_URL);

  console.log(`Found ${events.length} event(s):\n`);

  for (const event of events) {
    console.log('---');
    console.log(`Name:      ${event.name}`);
    console.log(`Date:      ${event.startTimestamp ? new Date(Number(event.startTimestamp) * 1000).toISOString() : 'N/A'}`);
    console.log(`Location:  ${event.location?.name ?? 'N/A'}`);
    console.log(`URL:       https://www.facebook.com/events/${event.id}`);
    console.log(`Photo:     ${event.photo?.imageUri ?? 'N/A'}`);
  }

  console.log('\n--- Raw JSON (first event) ---');
  if (events.length > 0) {
    console.log(JSON.stringify(events[0], null, 2));
  }
}

main().catch((err) => {
  console.error('Scraping failed:', err.message);
  process.exit(1);
});

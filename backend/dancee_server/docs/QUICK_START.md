# Dancee Server - Rychlý Start

Jednoduchý NestJS REST API server pro Dancee aplikaci s Facebook event scraperem.

## Spuštění

### 1. Vývojový režim (s hot reload)
```bash
task dev
```

Server se spustí na `http://localhost:3001`

### 2. Produkční režim
```bash
task build
task start
```

## Dostupné příkazy

- `task dev` - Spustit vývojový server s hot reload
- `task build` - Sestavit aplikaci
- `task start` - Spustit produkční server
- `task test` - Spustit testy
- `task lint` - Spustit linter
- `task format` - Formátovat kód

## API Endpointy

### GET /
Vrací jednoduchou "Hello World!" zprávu.

**Odpověď:**
```
Hello World!
```

### GET /scraper/event/:eventId
Scrapuje jeden Facebook event podle ID nebo URL.

**Parametry:**
- `eventId` (path parametr) - Facebook event ID nebo URL

**Příklad:**
```bash
GET http://localhost:3001/scraper/event/115982989234742
```

**Odpověď:**
```json
{
  "id": "115982989234742",
  "name": "Příklad Eventu",
  "description": "Popis eventu...",
  "location": {
    "name": "Název místa",
    "address": "Adresa 123",
    "city": { "name": "Praha" },
    "coordinates": {
      "latitude": 50.0755,
      "longitude": 14.4378
    }
  },
  "startTimestamp": 1681000200,
  "endTimestamp": 1681004700,
  "formattedDate": "Saturday, April 8, 2023 at 6:30 PM – 7:45 PM UTC-06",
  "hosts": [...],
  "usersResponded": 10
}
```

### GET /scraper/events?pageId=xxx&eventType=upcoming
Scrapuje seznam eventů z Facebook stránky, skupiny nebo profilu.

**Query parametry:**
- `pageId` (povinný) - Facebook page/group/profile ID nebo URL
- `eventType` (volitelný) - Filtr podle `upcoming` nebo `past` eventů

**Příklad:**
```bash
GET http://localhost:3001/scraper/events?pageId=123456789&eventType=upcoming
```

**Odpověď:**
```json
[
  {
    "id": "916236709985575",
    "name": "SILVESTR 2025",
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
  }
]
```

## Struktura projektu

```
src/
├── app.controller.ts       # Hlavní controller
├── app.module.ts           # Root modul
├── app.service.ts          # Business logika
├── main.ts                 # Vstupní bod aplikace
└── scraper/                # Facebook scraper modul
    ├── scraper.controller.ts   # Scraper endpointy
    ├── scraper.service.ts      # Scraper logika
    ├── scraper.module.ts       # Scraper modul
    └── dto/                    # Data transfer objects
        └── scrape-event.dto.ts
```

## Funkce

- ✅ CORS povoleno pro komunikaci s frontendem
- ✅ Hot reload ve vývojovém režimu
- ✅ TypeScript podpora
- ✅ ESLint a Prettier nakonfigurováno
- ✅ Jest testing setup
- ✅ Task automatizace s Taskfile
- ✅ Facebook event scraping
- ✅ Validace vstupů

## Poznámky

- Server běží na portu 3001 (konfigurovatelné přes PORT environment variable)
- CORS je povoleno pro požadavky z Flutter frontend aplikace
- Všechny příkazy lze spouštět buď přes `task` nebo přímo přes `npm run`
- Facebook scraper funguje pouze pro veřejné eventy (bez autentizace)

## Omezení

- Facebook scraper funguje pouze pro veřejné Facebook event stránky
- Facebook terms of service zakazují automatické scrapování jejich webu - používejte na vlastní riziko

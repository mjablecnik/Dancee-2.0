export function getEventTypeClassificationPrompt(): string {
  return `You are an expert in dance events. Your task is to classify the type of a dance event based on its description.

Classify the event into exactly one of the following types:
- party: A social dance party or ball
- workshop: A dance workshop or masterclass
- lesson: A regular dance lesson or class
- course: A multi-session dance course
- festival: A dance festival spanning multiple days
- holiday: A dance holiday or dance camp
- other: Any other type of event that does not fit the above categories

Respond with only the type name (lowercase), nothing else.`;
}

export function getEventPartsExtractionPrompt(outputLanguage: string, eventStartTime: string, eventEndTime: string | null): string {
  const timeContext = eventEndTime
    ? `The event starts at ${eventStartTime} and ends at ${eventEndTime}.`
    : `The event starts at ${eventStartTime}.`;

  return `You are an expert in dance events. Your task is to extract structured information from a dance event description.

${timeContext}
All part times MUST fall within the event's start and end time range. Do NOT invent dates from the description text — use the provided event times as reference.

Extract the event into a JSON object with the following structure:
{
  "title": "string - event title in ${outputLanguage}",
  "description": "string - concise event description in ${outputLanguage}",
  "parts": [
    {
      "name": "string - part name in ${outputLanguage}",
      "description": "string - part description in ${outputLanguage}",
      "type": "party | workshop | openLesson",
      "dances": ["string - dance style names (keep original names, do not translate)"],
      "date_time_range": {
        "start": "ISO 8601 datetime string (same date as event) or null if unknown",
        "end": "ISO 8601 datetime string (same date as event) or null if unknown"
      },
      "lectors": ["string - lector names (keep original names)"],
      "djs": ["string - DJ names (keep original names)"]
    }
  ]
}

Important rules:
- Output title and description in ${outputLanguage}
- Output part names and descriptions in ${outputLanguage}
- Do NOT translate dance names, lector names, or DJ names
- Part date_time_range values MUST use the same date as the event start time (${eventStartTime})
- If the description mentions specific hours (e.g. "20:00-02:00"), combine them with the event date
- If no specific times are mentioned for a part, set date_time_range start and end to null
- If no specific parts can be identified, create one part representing the whole event
- Respond with only valid JSON, no markdown fences or additional text`;
}

export function getEventInfoExtractionPrompt(): string {
  return `You are an expert in dance events. Your task is to extract additional information (prices, registration URLs) from a dance event description.

Extract the event info into a JSON array with the following structure:
[
  {
    "type": "url | price",
    "key": "string - label describing the info item (e.g., 'Registration', 'Early bird price')",
    "value": "string - the actual URL or price value"
  }
]

Important rules:
- Only include items with non-empty values
- For URLs, include the full URL as the value
- For prices, include the full price string including currency
- Do not include empty or null values
- Respond with only valid JSON, no markdown fences or additional text
- If no relevant info is found, respond with an empty array []`;
}

export function getTranslationPrompt(targetLanguage: string): string {
  return `You are a professional translator specializing in dance events. Translate the provided event content into ${targetLanguage}.

You will receive a JSON object with the following structure:
{
  "title": "string",
  "description": "string",
  "parts_translations": [
    {
      "name": "string",
      "description": "string"
    }
  ],
  "info_translations": [
    {
      "key": "string"
    }
  ]
}

Translate all text fields into ${targetLanguage} and return the same JSON structure.

Important rules:
- Translate: title, description, part names, part descriptions, and info keys
- Do NOT translate: dates, times, coordinates, URLs, price values, dance names, lector names, DJ names, organizer names, venue names
- Preserve the exact JSON structure including all field names
- Preserve all array lengths (parts_translations and info_translations must have the same number of items as the input)
- Respond with only valid JSON, no markdown fences or additional text`;
}

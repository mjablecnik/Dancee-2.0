# Requirements Document

## Introduction

The Event Detail Page is a feature within the Dancee App that displays comprehensive information about a single dance event. Users navigate to this page from the event list or favorites list by tapping on an event card. The page receives all event data directly from the already-loaded event list state — no additional API calls are needed. The page presents all event data in a scrollable layout with sections for title, date/time, dance styles, venue, organizer, description, additional info (prices, links), event parts (workshops, parties), and related actions (favorite toggle, map navigation). This spec covers completing the page to match the design reference and adding missing functionality (favorite toggle, external navigation).

## Glossary

- **Event_Detail_Page**: The Flutter page that displays full details of a single dance event, accessible via the route `/events/:id`.
- **Event_Detail_Cubit**: The Cubit responsible for managing the state of the Event Detail Page, including receiving event data from the event list state, toggling favorites, and handling errors.
- **Event_List_Cubit**: The existing Cubit that holds the loaded list of events. The Event Detail Page reads the selected event from this state.
- **Event_Repository**: The repository class that provides data access for event-related operations such as toggling favorites.
- **Favorite_Button**: The header action button that toggles the favorite status of the displayed event.
- **Navigate_Button**: The button in the venue section that opens an external map application for directions to the venue.
- **Map_Button**: The header quick-action button that opens an external map application showing the venue location.

## Requirements

### Requirement 1: Display Event Header

**User Story:** As a user, I want to see a visually distinct header with quick actions, so that I can quickly access key functions like going back, favoriting, and viewing the map.

#### Acceptance Criteria

1. THE Event_Detail_Page SHALL display a gradient header containing a back button and the page title.
2. WHEN the user taps the back button, THE Event_Detail_Page SHALL navigate back to the previous screen.
3. THE Event_Detail_Page SHALL display two quick-action buttons in the header: the Favorite_Button and the Map_Button.
4. THE Favorite_Button SHALL display a filled heart icon when the event is marked as favorite and an outlined heart icon when the event is not a favorite.

### Requirement 2: Display Event Title and Date/Time

**User Story:** As a user, I want to see the event name, venue name, date, time range, and a status badge, so that I can quickly understand the key details of the event.

#### Acceptance Criteria

1. THE Event_Detail_Page SHALL display the event title, the venue name, and a date/time info card.
2. WHEN the event has a badge value (e.g., "TODAY", "TOMORROW"), THE Event_Detail_Page SHALL display the badge next to the event title.
3. THE Event_Detail_Page SHALL display the event start date formatted as a localized day-of-week and date string.
4. THE Event_Detail_Page SHALL display the event time range formatted as "HH:MM - HH:MM" using the start and end times.
5. IF the event has no end time, THEN THE Event_Detail_Page SHALL display only the start time.

### Requirement 3: Display Dance Styles

**User Story:** As a user, I want to see which dance styles are featured at the event, so that I can decide if the event matches my interests.

#### Acceptance Criteria

1. THE Event_Detail_Page SHALL display a list of dance style tags with color-coded gradient chips.
2. IF the event has no dance styles, THEN THE Event_Detail_Page SHALL hide the dance styles section.

### Requirement 4: Display Venue Information

**User Story:** As a user, I want to see the venue name, description, and full address, so that I know where the event takes place.

#### Acceptance Criteria

1. THE Event_Detail_Page SHALL display the venue name, optional venue description, and full address (street, postal code, city).
2. THE Event_Detail_Page SHALL display the Navigate_Button in the venue section.
3. WHEN the user taps the Navigate_Button, THE Event_Detail_Page SHALL open an external map application with directions to the venue address.
4. IF the venue has latitude and longitude coordinates, THEN THE Event_Detail_Page SHALL use the coordinates for map navigation.
5. IF the venue has no coordinates, THEN THE Event_Detail_Page SHALL use the formatted address string for map navigation.

### Requirement 5: Display Organizer

**User Story:** As a user, I want to see who organizes the event, so that I can identify trusted event organizers.

#### Acceptance Criteria

1. THE Event_Detail_Page SHALL display the organizer name in a styled card with an icon.

### Requirement 6: Display Event Description

**User Story:** As a user, I want to read a detailed description of the event, so that I can learn more about what to expect.

#### Acceptance Criteria

1. WHEN the event has a description, THE Event_Detail_Page SHALL display the description text in a styled card.
2. IF the event has no description, THEN THE Event_Detail_Page SHALL hide the description section.

### Requirement 7: Display Additional Information

**User Story:** As a user, I want to see additional event details like entry fees, cloakroom info, and links, so that I can prepare for the event.

#### Acceptance Criteria

1. WHEN the event has additional info items, THE Event_Detail_Page SHALL display each info item as a styled card showing the key, value, and an icon based on the info type (price, url, text).
2. IF the event has no additional info items, THEN THE Event_Detail_Page SHALL hide the additional info section.
3. WHEN the user taps an info item of type "url", THE Event_Detail_Page SHALL open the URL in an external browser.

### Requirement 8: Display Event Parts

**User Story:** As a user, I want to see the event schedule with workshops, parties, and lessons, so that I can plan my attendance.

#### Acceptance Criteria

1. WHEN the event has parts, THE Event_Detail_Page SHALL display each part as a styled card showing the part name, type label, time range, and optional lectors or DJs.
2. IF the event has no parts, THEN THE Event_Detail_Page SHALL hide the event parts section.
3. THE Event_Detail_Page SHALL display the part type using a localized label (Workshop, Party, Open Lesson).

### Requirement 9: Toggle Favorite

**User Story:** As a user, I want to add or remove an event from my favorites directly from the detail page, so that I can manage my saved events without going back to the list.

#### Acceptance Criteria

1. WHEN the user taps the Favorite_Button, THE Event_Detail_Cubit SHALL call the Event_Repository to toggle the favorite status.
2. WHEN the favorite toggle succeeds, THE Event_Detail_Cubit SHALL update the event's favorite status in the local state.
3. WHEN the favorite toggle succeeds, THE Event_Detail_Page SHALL update the Favorite_Button icon to reflect the new status.
4. IF the favorite toggle fails, THEN THE Event_Detail_Page SHALL display a brief error message and revert the Favorite_Button to the previous state.

### Requirement 10: Map Navigation from Header

**User Story:** As a user, I want to quickly open the venue location on a map from the header, so that I can check the location without scrolling to the venue section.

#### Acceptance Criteria

1. WHEN the user taps the Map_Button in the header, THE Event_Detail_Page SHALL open an external map application showing the venue location.
2. THE Map_Button SHALL use the same navigation logic as the Navigate_Button in the venue section.

### Requirement 11: Localization

**User Story:** As a user, I want all text on the Event Detail Page to be displayed in my selected language, so that I can use the app comfortably.

#### Acceptance Criteria

1. THE Event_Detail_Page SHALL use slang translation keys for all user-facing static text.
2. WHEN new translation keys are added, THE translation files SHALL include entries for all three supported languages (en, cs, es).

# Requirements Document

## Introduction

This feature adds search and filtering capabilities to the Dancee App event list. Users can search events by name, and filter by dance type, location (Czech Republic regions), and date range. All filtering is performed locally on the device using already-fetched event data. Filter preferences are persisted to local storage and restored on app restart. The filter page UI follows the design in `.design/event-filters.html`.

## Glossary

- **Event_List_Page**: The main Flutter page displaying dance events grouped by date (today, tomorrow, upcoming).
- **Filter_Page**: A dedicated Flutter page for configuring filter criteria, following the design in `.design/event-filters.html`.
- **Search_Bar**: A text input field in the Event_List_Page header area for searching events by name.
- **Filter_State**: An immutable data object holding the current filter configuration (search query, selected dance types, selected regions, date range).
- **Event_Filter_Cubit**: A Cubit managing the Filter_State and applying filter logic to the event list.
- **Filter_Persistence_Service**: A service that saves and loads Filter_State to/from local storage using SharedPreferences.
- **Region**: A Czech Republic administrative region (kraj) or the capital city Prague, used for location-based filtering. Regions are derived from the `region` field on Directus venue objects (populated by Nominatim reverse geocoding).
- **Dance_Type**: A string identifier for a dance style (e.g., "Salsa", "Bachata") associated with events via the `dances` field.
- **Date_Range**: A pair of optional start and end dates used to filter events by their start time.
- **Quick_Date_Preset**: A predefined date range shortcut (Today, Tomorrow, This Week, Weekend).

## Requirements

### Requirement 1: Text Search in Event List

**User Story:** As a user, I want to search events by typing text in the event list, so that I can quickly find events by name.

#### Acceptance Criteria

1. THE Search_Bar SHALL be displayed in the Event_List_Page header area above the filter chips.
2. WHEN a user types text into the Search_Bar, THE Event_Filter_Cubit SHALL filter the loaded events where the event title contains the search query (case-insensitive), with a 300ms debounce delay to avoid excessive re-filtering on each keystroke.
3. WHEN the user clears the Search_Bar text, THE Event_Filter_Cubit SHALL display all events matching the remaining active filters.
4. THE Search_Bar SHALL include a clear button visible only when text is present.
5. WHEN the search query matches zero events, THE Event_List_Page SHALL display an empty state message.

### Requirement 2: Filter Page Navigation

**User Story:** As a user, I want to open a filter page from the event list, so that I can configure detailed filter criteria.

#### Acceptance Criteria

1. WHEN the user taps the "Filters" chip on the Event_List_Page, THE Event_List_Page SHALL navigate to the Filter_Page.
2. THE Filter_Page SHALL display sections for dance type, location, and date range following the layout in `.design/event-filters.html`.
3. THE Filter_Page SHALL display a back button that navigates back to the Event_List_Page.
4. THE Filter_Page SHALL display a reset button that clears all filter selections on the Filter_Page.
5. WHEN the user taps the date filter chip on the Event_List_Page, THE Filter_Page SHALL open and scroll to the date range section.
6. WHEN the user taps the location filter chip on the Event_List_Page, THE Filter_Page SHALL open and scroll to the location section.

### Requirement 3: Dance Type Filter

**User Story:** As a user, I want to filter events by dance type, so that I can see only events for dances I am interested in.

#### Acceptance Criteria

1. THE Filter_Page SHALL display a list of dance types extracted from the currently loaded events (from the `dances` field on each event).
2. THE Filter_Page SHALL allow the user to select multiple dance types using checkboxes.
3. WHEN one or more dance types are selected, THE Event_Filter_Cubit SHALL include only events that contain at least one of the selected dance types in the event `dances` list.
4. WHEN no dance types are selected, THE Event_Filter_Cubit SHALL not filter events by dance type.
5. THE Filter_Page SHALL display the count of matching events next to each dance type option, where the count reflects events matching all other active filters (cross-filter count) plus the given dance type.
6. THE Filter_Page SHALL provide a "Clear" button for the dance type section that deselects all dance types.

### Requirement 4: Location Filter by Region

**User Story:** As a user, I want to filter events by Czech Republic region, so that I can see events near my area.

#### Acceptance Criteria

1. THE Filter_Page SHALL display a list of regions derived from the `region` field of venue data on loaded events.
2. THE Filter_Page SHALL allow the user to select multiple regions using checkboxes.
3. WHEN one or more regions are selected, THE Event_Filter_Cubit SHALL include only events whose venue region matches one of the selected regions.
4. WHEN no regions are selected, THE Event_Filter_Cubit SHALL not filter events by location.
5. THE Filter_Page SHALL display the count of matching events next to each region option, where the count reflects events matching all other active filters (cross-filter count) plus the given region.
6. THE Filter_Page SHALL provide a "Clear" button for the location section that deselects all regions.
7. THE Venue entity in the Flutter app SHALL include a `region` field parsed from the Directus venue `region` property.

### Requirement 5: Date Range Filter

**User Story:** As a user, I want to filter events by date range, so that I can see events happening in a specific time period.

#### Acceptance Criteria

1. THE Filter_Page SHALL display "From" and "To" date input fields for selecting a date range.
2. WHEN a date range is set, THE Event_Filter_Cubit SHALL include only events whose start time falls within the selected date range (inclusive on both ends).
3. WHEN only a "From" date is set, THE Event_Filter_Cubit SHALL include only events starting on or after the "From" date.
4. WHEN only a "To" date is set, THE Event_Filter_Cubit SHALL include only events starting on or before the "To" date.
5. WHEN no dates are set, THE Event_Filter_Cubit SHALL not filter events by date.
6. THE Filter_Page SHALL display quick-select preset buttons for Today, Tomorrow, This Week, and Weekend.
7. WHEN the user taps a Quick_Date_Preset button, THE Filter_Page SHALL populate the "From" and "To" date fields with the corresponding date range.
8. THE Filter_Page SHALL provide a "Clear" button for the date section that clears both date fields.

### Requirement 6: Combined Filter Logic

**User Story:** As a user, I want all filters to work together, so that I can narrow down events using multiple criteria simultaneously.

#### Acceptance Criteria

1. THE Event_Filter_Cubit SHALL apply all active filters (search query, dance types, regions, date range) using AND logic — an event is included only when the event matches all active filter criteria.
2. THE Event_Filter_Cubit SHALL perform all filtering locally on the device using the already-loaded event list without making API requests.
3. THE Filter_Page SHALL display an active filters summary showing the number of active filter categories.
4. WHEN the user taps "Apply filters" on the Filter_Page, THE Filter_Page SHALL navigate back to the Event_List_Page and the Event_List_Page SHALL display the filtered events.
5. WHEN the user taps "Clear all" on the Filter_Page, THE Event_Filter_Cubit SHALL reset all filters to their default (empty) state.

### Requirement 9: Live Filter Result Preview

**User Story:** As a user, I want to see how many events match my current filter selections before I apply them, so that I can adjust filters without leaving the filter page.

#### Acceptance Criteria

1. THE Filter_Page SHALL display a live count of matching events in the footer area (e.g., "Show 42 events") that updates in real time as the user changes any filter selection.
2. THE live count SHALL reflect the combined result of all current filter selections on the Filter_Page (dance types, regions, date range) applied with AND logic.
3. THE live count SHALL update immediately when the user selects or deselects any filter option, without requiring the user to tap "Apply".
4. WHEN the live count is zero, THE Filter_Page SHALL indicate that no events match the current filter combination.

### Requirement 7: Filter Persistence

**User Story:** As a user, I want my filters to live in memory by default, but optionally save them so they persist after restarting the app.

#### Acceptance Criteria

1. BY DEFAULT, THE Event_Filter_Cubit SHALL hold the current Filter_State only in memory — filters are lost when the app is closed or restarted.
2. THE Filter_Page SHALL provide a "Save filters" action that persists the current Filter_State to local storage using SharedPreferences.
3. WHEN the app starts and a saved Filter_State exists in local storage, THE Filter_Persistence_Service SHALL restore it into the Event_Filter_Cubit.
4. IF the saved Filter_State cannot be read or is corrupted, THEN THE Filter_Persistence_Service SHALL use the default empty Filter_State.
5. WHEN the user resets all filters, THE Filter_Persistence_Service SHALL clear the saved Filter_State from local storage.
6. WHEN the user applies filters WITHOUT saving, THE filters SHALL be active for the current session only and SHALL NOT be written to local storage.

### Requirement 8: Filter Chips on Event List

**User Story:** As a user, I want to see active filter indicators on the event list, so that I know which filters are currently applied.

#### Acceptance Criteria

1. THE Event_List_Page SHALL display a "Filters" chip that shows the count of active filter categories as a badge.
2. THE Event_List_Page SHALL display a date chip that, when tapped, opens the Filter_Page scrolled to the date section.
3. THE Event_List_Page SHALL display a location chip that, when tapped, opens the Filter_Page scrolled to the location section.
4. WHEN filters are active, THE Event_List_Page SHALL visually distinguish active filter chips from inactive ones.

### Requirement 10: Internationalization

**User Story:** As a user, I want the search and filter UI to be fully translated, so that I can use it in my preferred language.

#### Acceptance Criteria

1. ALL user-facing strings in the Search_Bar, Filter_Page, filter chips, and related UI elements SHALL be defined in the slang i18n translation files (en, cs, es) and accessed via the `t` global variable.
2. NO user-facing string SHALL be hardcoded in Dart source code.
3. WHEN new translation keys are added, THEY SHALL be added to all three language files: `strings.i18n.json` (en), `strings_cs.i18n.json` (cs), and `strings_es.i18n.json` (es).
4. Parameterized strings (e.g., "Show {count} events") SHALL use slang named parameter syntax.

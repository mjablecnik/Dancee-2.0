package services

import (
	"errors"
	"fmt"
	"time"

	"dancee_events/internal/models"
	"dancee_events/internal/repositories"
)

// EventService handles business logic for events
type EventService struct {
	eventRepo     *repositories.EventRepository
	favoritesRepo *repositories.FavoritesRepository
}

// NewEventService creates a new event service
func NewEventService(eventRepo *repositories.EventRepository, favoritesRepo *repositories.FavoritesRepository) *EventService {
	return &EventService{
		eventRepo:     eventRepo,
		favoritesRepo: favoritesRepo,
	}
}

// calculateIsPast determines if an event has already ended
func calculateIsPast(event *models.Event) bool {
	now := time.Now()
	
	// Use EndTime if available, otherwise use StartTime
	timeToCheck := event.StartTime
	if event.EndTime != nil && *event.EndTime != "" {
		timeToCheck = *event.EndTime
	}
	
	// Parse the time string (ISO 8601 format)
	eventTime, err := time.Parse(time.RFC3339, timeToCheck)
	if err != nil {
		// If parsing fails, assume event is not past
		return false
	}
	
	// Event is past if the end time (or start time) is before now
	return eventTime.Before(now)
}

// markEventStatus marks an event with isPast status
func markEventStatus(event *models.Event) {
	isPast := calculateIsPast(event)
	event.IsPast = &isPast
}

// GetAllEvents retrieves all events, optionally marking favorites for a user
func (s *EventService) GetAllEvents(userID string) ([]models.Event, error) {
	events, err := s.eventRepo.GetAllEvents()
	if err != nil {
		return nil, err
	}

	// If no userID provided, mark isPast status and return
	if userID == "" {
		for i := range events {
			markEventStatus(&events[i])
		}
		return events, nil
	}

	// Get user's favorite event IDs
	favorites, err := s.favoritesRepo.GetFavorites(userID)
	if err != nil {
		return nil, err
	}

	favoriteIDs := make(map[string]bool)
	for _, fav := range favorites {
		favoriteIDs[fav.ID] = true
	}

	// Mark events as favorite and calculate isPast status
	for i := range events {
		isFav := favoriteIDs[events[i].ID]
		events[i].IsFavorite = &isFav
		markEventStatus(&events[i])
	}

	return events, nil
}

// GetFavorites retrieves all favorite events for a user
func (s *EventService) GetFavorites(userID string) ([]models.Event, error) {
	favorites, err := s.favoritesRepo.GetFavorites(userID)
	if err != nil {
		return nil, err
	}
	
	// Mark isPast status for all favorite events
	for i := range favorites {
		markEventStatus(&favorites[i])
	}
	
	return favorites, nil
}

// AddFavorite adds an event to user's favorites
func (s *EventService) AddFavorite(userID, eventID string) error {
	// Validate that event exists
	event, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return errors.New("event not found")
	}

	// Mark event as favorite
	isFav := true
	event.IsFavorite = &isFav

	return s.favoritesRepo.AddFavorite(userID, event)
}

// RemoveFavorite removes an event from user's favorites
func (s *EventService) RemoveFavorite(userID, eventID string) error {
	// Validate that event exists
	exists, err := s.eventRepo.EventExists(eventID)
	if err != nil || !exists {
		return errors.New("event not found")
	}

	return s.favoritesRepo.RemoveFavorite(userID, eventID)
}

// SeedEvents generates and saves 10 sample dance events to the database.
// TODO: Remove this method once Facebook event scraping is fully implemented.
func (s *EventService) SeedEvents() ([]models.Event, error) {
	dances := [][]string{
		{"Salsa", "Bachata"},
		{"Kizomba", "Semba"},
		{"Zouk", "Lambada"},
		{"West Coast Swing"},
		{"Lindy Hop", "Charleston"},
		{"Tango"},
		{"Salsa", "Bachata", "Kizomba"},
		{"Zouk"},
		{"West Coast Swing", "Hustle"},
		{"Lindy Hop", "Balboa", "Blues"},
	}

	venues := []models.Venue{
		{Name: "Lucerna Music Bar", Address: models.Address{Street: "Vodičkova 36", City: "Prague", PostalCode: "110 00", Country: "Czech Republic"}},
		{Name: "SaSaZu", Address: models.Address{Street: "Bubenské nábřeží 306", City: "Prague", PostalCode: "170 00", Country: "Czech Republic"}},
		{Name: "Jazz Dock", Address: models.Address{Street: "Janáčkovo nábřeží 2", City: "Prague", PostalCode: "150 00", Country: "Czech Republic"}},
		{Name: "Roxy", Address: models.Address{Street: "Dlouhá 33", City: "Prague", PostalCode: "110 00", Country: "Czech Republic"}},
		{Name: "Palác Akropolis", Address: models.Address{Street: "Kubelíkova 27", City: "Prague", PostalCode: "130 00", Country: "Czech Republic"}},
	}

	titles := []string{
		"Prague Salsa Night",
		"Kizomba Fever",
		"Zouk Weekend Party",
		"WCS Social Night",
		"Swing Jam Session",
		"Tango Milonga",
		"Latin Dance Festival",
		"Zouk Flow Evening",
		"Hustle & Swing Night",
		"Vintage Swing Ball",
	}

	organizers := []string{
		"Prague Salsa Club",
		"Kizomba Prague",
		"Zouk Academy CZ",
		"WCS Czech Republic",
		"Prague Swing Society",
		"Tango Prague",
		"Latin Vibes CZ",
		"Zouk Flow Prague",
		"Dance Connection CZ",
		"Swing Time Prague",
	}

	now := time.Now()
	var created []models.Event

	for i := 0; i < 10; i++ {
		startTime := now.AddDate(0, 0, i+1).Truncate(time.Hour).Add(20 * time.Hour)
		endTime := startTime.Add(5 * time.Hour)
		endStr := endTime.Format(time.RFC3339)
		duration := int64(endTime.Sub(startTime).Milliseconds())
		desc := "Join us for an amazing night of dancing!"

		event := models.Event{
			ID:          fmt.Sprintf("seed-%d-%d", now.Unix(), i),
			Title:       titles[i],
			Description: &desc,
			Organizer:   organizers[i],
			Venue:       venues[i%len(venues)],
			StartTime:   startTime.Format(time.RFC3339),
			EndTime:     &endStr,
			Duration:    &duration,
			Dances:      dances[i],
			Info: []models.EventInfo{
				{Type: "price", Key: "Entry Fee", Value: fmt.Sprintf("%d Kč", 150+i*50)},
			},
			Parts: []models.EventPart{
				{
					Name:      "Social Dancing",
					Type:      "party",
					StartTime: startTime.Format(time.RFC3339),
					EndTime:   &endStr,
				},
			},
		}

		if err := s.eventRepo.SaveEvent(&event); err != nil {
			return nil, fmt.Errorf("failed to save event %s: %w", event.ID, err)
		}
		created = append(created, event)
	}

	return created, nil
}

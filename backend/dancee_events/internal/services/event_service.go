package services

import (
	"errors"
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

// CreateEvent creates a new event via the repository and returns it with the generated ID
func (s *EventService) CreateEvent(event *models.Event) (*models.Event, error) {
	id, err := s.eventRepo.CreateEvent(event)
	if err != nil {
		return nil, err
	}

	event.ID = id
	return event, nil
}

// UpdateEvent checks that the event exists, updates it via the repository, and returns the updated event
func (s *EventService) UpdateEvent(eventID string, event *models.Event) (*models.Event, error) {
	// Check event exists
	_, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return nil, errors.New("event not found")
	}

	// Update event via repository
	if err := s.eventRepo.UpdateEvent(eventID, event); err != nil {
		return nil, err
	}

	// Set the ID on the returned event
	event.ID = eventID
	return event, nil
}

// DeleteEvent checks that the event exists, deletes it via the repository,
// and cascades the deletion to all user favorites
func (s *EventService) DeleteEvent(eventID string) error {
	// Check event exists
	_, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return errors.New("event not found")
	}

	// Delete event via repository
	if err := s.eventRepo.DeleteEvent(eventID); err != nil {
		return err
	}

	// Cascade delete favorites
	if err := s.favoritesRepo.RemoveFavoritesByEventID(eventID); err != nil {
		return err
	}

	return nil
}

// GetEventByID retrieves a single event by ID, optionally marking favorite status for a user
func (s *EventService) GetEventByID(eventID, userID string) (*models.Event, error) {
	// Retrieve the event from repository
	event, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return nil, errors.New("event not found")
	}

	// Mark isPast status
	markEventStatus(event)

	// If userID provided, check if event is in user's favorites
	if userID != "" {
		favorites, err := s.favoritesRepo.GetFavorites(userID)
		if err != nil {
			return nil, err
		}

		isFav := false
		for _, fav := range favorites {
			if fav.ID == eventID {
				isFav = true
				break
			}
		}
		event.IsFavorite = &isFav
	}

	return event, nil
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



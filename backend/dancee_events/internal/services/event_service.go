package services

import (
	"errors"

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

// GetAllEvents retrieves all events, optionally marking favorites for a user
func (s *EventService) GetAllEvents(userID string) ([]models.Event, error) {
	events, err := s.eventRepo.GetAllEvents()
	if err != nil {
		return nil, err
	}

	// If no userID provided, return events as-is
	if userID == "" {
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

	// Mark events as favorite if they are in user's favorites
	for i := range events {
		isFav := favoriteIDs[events[i].ID]
		events[i].IsFavorite = &isFav
	}

	return events, nil
}

// GetFavorites retrieves all favorite events for a user
func (s *EventService) GetFavorites(userID string) ([]models.Event, error) {
	return s.favoritesRepo.GetFavorites(userID)
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

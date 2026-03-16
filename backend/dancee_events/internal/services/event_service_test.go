package services

import (
	"errors"
	"reflect"
	"strings"
	"sync"
	"testing"
	"time"

	"dancee_events/internal/models"

	"pgregory.net/rapid"
)

// ============================================================================
// Repository Interfaces for Testing
// ============================================================================

// EventRepositoryInterface defines the interface for event repository operations.
// This allows us to create mock implementations for testing.
type EventRepositoryInterface interface {
	GetAllEvents() ([]models.Event, error)
	GetEventByID(eventID string) (*models.Event, error)
	EventExists(eventID string) (bool, error)
	CreateEvent(event *models.Event) (string, error)
	UpdateEvent(eventID string, event *models.Event) error
	DeleteEvent(eventID string) error
}

// FavoritesRepositoryInterface defines the interface for favorites repository operations.
type FavoritesRepositoryInterface interface {
	GetFavorites(userID string) ([]models.Event, error)
	AddFavorite(userID string, event *models.Event) error
	RemoveFavorite(userID, eventID string) error
	RemoveFavoritesByEventID(eventID string) error
}

// ============================================================================
// Mock Event Repository
// ============================================================================

// MockEventRepository is an in-memory implementation of EventRepositoryInterface.
type MockEventRepository struct {
	mu       sync.RWMutex
	events   map[string]*models.Event
	idCounter int
}

// NewMockEventRepository creates a new mock event repository.
func NewMockEventRepository() *MockEventRepository {
	return &MockEventRepository{
		events:   make(map[string]*models.Event),
		idCounter: 0,
	}
}

// GetAllEvents returns all events from the in-memory store.
func (r *MockEventRepository) GetAllEvents() ([]models.Event, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	events := make([]models.Event, 0, len(r.events))
	for _, event := range r.events {
		eventCopy := *event
		events = append(events, eventCopy)
	}
	return events, nil
}

// GetEventByID retrieves a single event by ID.
func (r *MockEventRepository) GetEventByID(eventID string) (*models.Event, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	event, exists := r.events[eventID]
	if !exists {
		return nil, errors.New("event not found")
	}
	eventCopy := *event
	return &eventCopy, nil
}

// EventExists checks if an event exists in the in-memory store.
func (r *MockEventRepository) EventExists(eventID string) (bool, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	_, exists := r.events[eventID]
	return exists, nil
}

// CreateEvent creates a new event with an auto-generated ID.
func (r *MockEventRepository) CreateEvent(event *models.Event) (string, error) {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.idCounter++
	id := "mock-" + time.Now().Format("20060102150405") + "-" + string(rune('0'+r.idCounter))
	eventCopy := *event
	eventCopy.ID = id
	r.events[id] = &eventCopy
	return id, nil
}

// UpdateEvent overwrites an existing event in the in-memory store.
func (r *MockEventRepository) UpdateEvent(eventID string, event *models.Event) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	if _, exists := r.events[eventID]; !exists {
		return errors.New("event not found")
	}
	eventCopy := *event
	eventCopy.ID = eventID
	r.events[eventID] = &eventCopy
	return nil
}

// DeleteEvent deletes an event from the in-memory store.
func (r *MockEventRepository) DeleteEvent(eventID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	delete(r.events, eventID)
	return nil
}

// Reset clears all events from the in-memory store.
func (r *MockEventRepository) Reset() {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.events = make(map[string]*models.Event)
	r.idCounter = 0
}

// ============================================================================
// Mock Favorites Repository
// ============================================================================

// MockFavoritesRepository is an in-memory implementation of FavoritesRepositoryInterface.
// Structure: map[userID]map[eventID]*Event
type MockFavoritesRepository struct {
	mu        sync.RWMutex
	favorites map[string]map[string]*models.Event
}

// NewMockFavoritesRepository creates a new mock favorites repository.
func NewMockFavoritesRepository() *MockFavoritesRepository {
	return &MockFavoritesRepository{
		favorites: make(map[string]map[string]*models.Event),
	}
}

// GetFavorites retrieves all favorite events for a user.
func (r *MockFavoritesRepository) GetFavorites(userID string) ([]models.Event, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	userFavs, exists := r.favorites[userID]
	if !exists {
		return []models.Event{}, nil
	}

	events := make([]models.Event, 0, len(userFavs))
	for _, event := range userFavs {
		eventCopy := *event
		events = append(events, eventCopy)
	}
	return events, nil
}

// AddFavorite adds an event to a user's favorites.
func (r *MockFavoritesRepository) AddFavorite(userID string, event *models.Event) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	if _, exists := r.favorites[userID]; !exists {
		r.favorites[userID] = make(map[string]*models.Event)
	}
	eventCopy := *event
	r.favorites[userID][event.ID] = &eventCopy
	return nil
}

// RemoveFavorite removes an event from a user's favorites.
func (r *MockFavoritesRepository) RemoveFavorite(userID, eventID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	if userFavs, exists := r.favorites[userID]; exists {
		delete(userFavs, eventID)
	}
	return nil
}

// RemoveFavoritesByEventID removes a specific event from all users' favorites.
func (r *MockFavoritesRepository) RemoveFavoritesByEventID(eventID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	for userID, userFavs := range r.favorites {
		delete(userFavs, eventID)
		if len(userFavs) == 0 {
			delete(r.favorites, userID)
		}
	}
	return nil
}

// HasFavorite checks if a user has a specific event in their favorites.
func (r *MockFavoritesRepository) HasFavorite(userID, eventID string) bool {
	r.mu.RLock()
	defer r.mu.RUnlock()

	if userFavs, exists := r.favorites[userID]; exists {
		_, hasFav := userFavs[eventID]
		return hasFav
	}
	return false
}

// Reset clears all favorites from the in-memory store.
func (r *MockFavoritesRepository) Reset() {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.favorites = make(map[string]map[string]*models.Event)
}

// ============================================================================
// TestEventService - Wraps business logic using interfaces
// ============================================================================

// TestEventService mirrors EventService but uses interfaces instead of concrete types.
// This allows property-based tests to run against in-memory mock repositories.
type TestEventService struct {
	eventRepo    EventRepositoryInterface
	favoritesRepo FavoritesRepositoryInterface
}

// NewTestEventService creates a new test event service with mock repositories.
func NewTestEventService(eventRepo EventRepositoryInterface, favoritesRepo FavoritesRepositoryInterface) *TestEventService {
	return &TestEventService{
		eventRepo:    eventRepo,
		favoritesRepo: favoritesRepo,
	}
}

// GetEventByID retrieves a single event by ID, optionally marking favorite status.
func (s *TestEventService) GetEventByID(eventID, userID string) (*models.Event, error) {
	event, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return nil, errors.New("event not found")
	}

	// Mark isPast status using the same logic as the real service
	markEventStatus(event)

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

// CreateEvent creates a new event via the repository.
func (s *TestEventService) CreateEvent(event *models.Event) (*models.Event, error) {
	id, err := s.eventRepo.CreateEvent(event)
	if err != nil {
		return nil, err
	}

	event.ID = id
	return event, nil
}

// UpdateEvent checks that the event exists, then updates it.
func (s *TestEventService) UpdateEvent(eventID string, event *models.Event) (*models.Event, error) {
	_, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return nil, errors.New("event not found")
	}

	if err := s.eventRepo.UpdateEvent(eventID, event); err != nil {
		return nil, err
	}

	event.ID = eventID
	return event, nil
}

// DeleteEvent checks that the event exists, deletes it, and cascades to favorites.
func (s *TestEventService) DeleteEvent(eventID string) error {
	_, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return errors.New("event not found")
	}

	if err := s.eventRepo.DeleteEvent(eventID); err != nil {
		return err
	}

	if err := s.favoritesRepo.RemoveFavoritesByEventID(eventID); err != nil {
		return err
	}

	return nil
}

// AddFavorite adds an event to a user's favorites.
func (s *TestEventService) AddFavorite(userID, eventID string) error {
	event, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return errors.New("event not found")
	}

	isFav := true
	event.IsFavorite = &isFav

	return s.favoritesRepo.AddFavorite(userID, event)
}

// ============================================================================
// Test Setup Helpers
// ============================================================================

// TestSetup holds the mock repositories and test service for a test run.
type TestSetup struct {
	EventRepo    *MockEventRepository
	FavoritesRepo *MockFavoritesRepository
	Service      *TestEventService
}

// NewTestSetup creates a fresh test setup with empty mock repositories.
func NewTestSetup() *TestSetup {
	eventRepo := NewMockEventRepository()
	favoritesRepo := NewMockFavoritesRepository()
	service := NewTestEventService(eventRepo, favoritesRepo)
	return &TestSetup{
		EventRepo:    eventRepo,
		FavoritesRepo: favoritesRepo,
		Service:      service,
	}
}

// ============================================================================
// Rapid Generators
// ============================================================================

// genNonEmptyString generates a non-empty alphanumeric string.
func genNonEmptyString(t *rapid.T, label string) string {
	return rapid.StringMatching(`[a-zA-Z0-9 ]{1,50}`).Draw(t, label)
}

// genOptionalString generates an optional string pointer.
func genOptionalString(t *rapid.T, label string) *string {
	if rapid.Bool().Draw(t, label+"-present") {
		s := genNonEmptyString(t, label)
		return &s
	}
	return nil
}

// genAddress generates a random Address.
func genAddress(t *rapid.T) models.Address {
	return models.Address{
		Street:     genNonEmptyString(t, "street"),
		City:       genNonEmptyString(t, "city"),
		PostalCode: genNonEmptyString(t, "postalCode"),
		Country:    genNonEmptyString(t, "country"),
	}
}

// genVenue generates a random Venue.
func genVenue(t *rapid.T) models.Venue {
	return models.Venue{
		Name:        genNonEmptyString(t, "venueName"),
		Address:     genAddress(t),
		Description: genOptionalString(t, "venueDescription"),
	}
}

// genDances generates a non-empty slice of dance names.
func genDances(t *rapid.T) []string {
	count := rapid.IntRange(1, 5).Draw(t, "danceCount")
	dances := make([]string, count)
	for i := 0; i < count; i++ {
		dances[i] = genNonEmptyString(t, "dance")
	}
	return dances
}

// genFutureTimeRFC3339 generates a time string in RFC3339 format that is in the future.
func genFutureTimeRFC3339(t *rapid.T) string {
	hoursAhead := rapid.IntRange(1, 8760).Draw(t, "hoursAhead") // 1 hour to 1 year ahead
	futureTime := time.Now().Add(time.Duration(hoursAhead) * time.Hour)
	return futureTime.Format(time.RFC3339)
}

// genPastTimeRFC3339 generates a time string in RFC3339 format that is in the past.
func genPastTimeRFC3339(t *rapid.T) string {
	hoursAgo := rapid.IntRange(1, 8760).Draw(t, "hoursAgo") // 1 hour to 1 year ago
	pastTime := time.Now().Add(-time.Duration(hoursAgo) * time.Hour)
	return pastTime.Format(time.RFC3339)
}

// genValidEvent generates a random valid Event with all required fields populated.
// The event will have a future start time by default.
func genValidEvent(t *rapid.T) *models.Event {
	startTime := genFutureTimeRFC3339(t)
	endTime := genOptionalString(t, "endTime")

	return &models.Event{
		Title:       genNonEmptyString(t, "title"),
		Description: genOptionalString(t, "description"),
		Organizer:   genNonEmptyString(t, "organizer"),
		Venue:       genVenue(t),
		StartTime:   startTime,
		EndTime:     endTime,
		Dances:      genDances(t),
	}
}

// genValidCreateRequest generates a random valid CreateEventRequest.
func genValidCreateRequest(t *rapid.T) *models.CreateEventRequest {
	startTime := genFutureTimeRFC3339(t)
	endTime := genOptionalString(t, "endTime")

	return &models.CreateEventRequest{
		Title:       genNonEmptyString(t, "title"),
		Description: genOptionalString(t, "description"),
		Organizer:   genNonEmptyString(t, "organizer"),
		Venue:       genVenue(t),
		StartTime:   startTime,
		EndTime:     endTime,
		Dances:      genDances(t),
	}
}

// genUserID generates a random user ID string.
func genUserID(t *rapid.T) string {
	return rapid.StringMatching(`user-[a-z0-9]{4,10}`).Draw(t, "userID")
}

// ============================================================================
// Smoke Test - Verify test infrastructure works
// ============================================================================

func TestInfrastructure_SmokeTest(t *testing.T) {
	setup := NewTestSetup()

	// Create an event
	event := &models.Event{
		Title:     "Test Event",
		Organizer: "Test Org",
		Venue: models.Venue{
			Name: "Test Venue",
			Address: models.Address{
				Street:     "123 Test St",
				City:       "Test City",
				PostalCode: "12345",
				Country:    "CZ",
			},
		},
		StartTime: time.Now().Add(24 * time.Hour).Format(time.RFC3339),
		Dances:    []string{"salsa", "bachata"},
	}

	created, err := setup.Service.CreateEvent(event)
	if err != nil {
		t.Fatalf("failed to create event: %v", err)
	}
	if created.ID == "" {
		t.Fatal("created event should have an ID")
	}

	// Retrieve the event
	retrieved, err := setup.Service.GetEventByID(created.ID, "")
	if err != nil {
		t.Fatalf("failed to get event: %v", err)
	}
	if retrieved.Title != "Test Event" {
		t.Fatalf("expected title 'Test Event', got '%s'", retrieved.Title)
	}

	// Verify rapid generators work
	rapid.Check(t, func(t *rapid.T) {
		evt := genValidEvent(t)
		if evt.Title == "" {
			t.Fatal("generated event should have a non-empty title")
		}
		if len(evt.Dances) == 0 {
			t.Fatal("generated event should have at least one dance")
		}
	})
}

// ============================================================================
// Property 1: GET event returns correct data with correct isFavorite
// **Validates: Requirements 1.1, 1.2**
// ============================================================================

func TestProperty_GetEventReturnsCorrectDataWithIsFavorite(t *testing.T) {
	rapid.Check(t, func(t *rapid.T) {
		setup := NewTestSetup()

		// Generate and create a random event
		event := genValidEvent(t)
		created, err := setup.Service.CreateEvent(event)
		if err != nil {
			t.Fatalf("failed to create event: %v", err)
		}

		userID := genUserID(t)
		shouldFavorite := rapid.Bool().Draw(t, "shouldFavorite")

		if shouldFavorite {
			err := setup.Service.AddFavorite(userID, created.ID)
			if err != nil {
				t.Fatalf("failed to add favorite: %v", err)
			}
		}

		// Case 1: GET with userId
		retrieved, err := setup.Service.GetEventByID(created.ID, userID)
		if err != nil {
			t.Fatalf("failed to get event with userId: %v", err)
		}

		// Verify returned data matches created event
		if retrieved.ID != created.ID {
			t.Fatalf("expected ID %q, got %q", created.ID, retrieved.ID)
		}
		if retrieved.Title != created.Title {
			t.Fatalf("expected title %q, got %q", created.Title, retrieved.Title)
		}
		if retrieved.Organizer != created.Organizer {
			t.Fatalf("expected organizer %q, got %q", created.Organizer, retrieved.Organizer)
		}
		if retrieved.Venue.Name != created.Venue.Name {
			t.Fatalf("expected venue name %q, got %q", created.Venue.Name, retrieved.Venue.Name)
		}
		if retrieved.Venue.Address.Street != created.Venue.Address.Street {
			t.Fatalf("expected venue street %q, got %q", created.Venue.Address.Street, retrieved.Venue.Address.Street)
		}
		if retrieved.Venue.Address.City != created.Venue.Address.City {
			t.Fatalf("expected venue city %q, got %q", created.Venue.Address.City, retrieved.Venue.Address.City)
		}
		if retrieved.StartTime != created.StartTime {
			t.Fatalf("expected startTime %q, got %q", created.StartTime, retrieved.StartTime)
		}
		if len(retrieved.Dances) != len(created.Dances) {
			t.Fatalf("expected %d dances, got %d", len(created.Dances), len(retrieved.Dances))
		}
		for i, dance := range created.Dances {
			if retrieved.Dances[i] != dance {
				t.Fatalf("expected dance[%d] %q, got %q", i, dance, retrieved.Dances[i])
			}
		}

		// Verify isFavorite when userId is provided
		if retrieved.IsFavorite == nil {
			t.Fatal("isFavorite should not be nil when userId is provided")
		}
		if shouldFavorite && !*retrieved.IsFavorite {
			t.Fatal("isFavorite should be true when event is favorited by user")
		}
		if !shouldFavorite && *retrieved.IsFavorite {
			t.Fatal("isFavorite should be false when event is NOT favorited by user")
		}

		// Case 2: GET without userId
		retrievedNoUser, err := setup.Service.GetEventByID(created.ID, "")
		if err != nil {
			t.Fatalf("failed to get event without userId: %v", err)
		}

		// Verify data still matches
		if retrievedNoUser.Title != created.Title {
			t.Fatalf("expected title %q, got %q", created.Title, retrievedNoUser.Title)
		}

		// Verify isFavorite is nil when no userId is provided
		if retrievedNoUser.IsFavorite != nil {
			t.Fatalf("isFavorite should be nil when no userId is provided, got %v", *retrievedNoUser.IsFavorite)
		}
	})
}

// ============================================================================
// Property 2: isPast is correctly computed
// **Validates: Requirements 1.4**
// ============================================================================

func TestProperty_IsPastIsCorrectlyComputed(t *testing.T) {
	rapid.Check(t, func(t *rapid.T) {
		setup := NewTestSetup()

		// Generate base event data
		event := genValidEvent(t)

		// Decide whether to use past or future times
		usePastStartTime := rapid.Bool().Draw(t, "usePastStartTime")
		hasEndTime := rapid.Bool().Draw(t, "hasEndTime")
		usePastEndTime := rapid.Bool().Draw(t, "usePastEndTime")

		// Set startTime based on decision
		if usePastStartTime {
			event.StartTime = genPastTimeRFC3339(t)
		} else {
			event.StartTime = genFutureTimeRFC3339(t)
		}

		// Set endTime based on decision
		if hasEndTime {
			var endTimeStr string
			if usePastEndTime {
				endTimeStr = genPastTimeRFC3339(t)
			} else {
				endTimeStr = genFutureTimeRFC3339(t)
			}
			event.EndTime = &endTimeStr
		} else {
			event.EndTime = nil
		}

		// Create the event
		created, err := setup.Service.CreateEvent(event)
		if err != nil {
			t.Fatalf("failed to create event: %v", err)
		}

		// Retrieve the event to get the computed isPast
		retrieved, err := setup.Service.GetEventByID(created.ID, "")
		if err != nil {
			t.Fatalf("failed to get event: %v", err)
		}

		// Verify isPast is set
		if retrieved.IsPast == nil {
			t.Fatal("isPast should not be nil")
		}

		// Determine expected isPast value based on the logic:
		// - If endTime is set and non-empty, use endTime
		// - Otherwise, use startTime
		// - isPast is true if the relevant time is in the past
		var expectedIsPast bool
		if hasEndTime {
			// endTime is set, so isPast should be based on endTime
			expectedIsPast = usePastEndTime
		} else {
			// No endTime, so isPast should be based on startTime
			expectedIsPast = usePastStartTime
		}

		if *retrieved.IsPast != expectedIsPast {
			t.Fatalf("isPast mismatch: expected %v, got %v (hasEndTime=%v, usePastEndTime=%v, usePastStartTime=%v, startTime=%s, endTime=%v)",
				expectedIsPast, *retrieved.IsPast, hasEndTime, usePastEndTime, usePastStartTime, event.StartTime, event.EndTime)
		}
	})
}


// ============================================================================
// Property 3: Non-existent ID returns 404
// **Validates: Requirements 1.3, 3.2, 4.2**
// ============================================================================

func TestProperty_NonExistentIDReturnsNotFound(t *testing.T) {
	rapid.Check(t, func(t *rapid.T) {
		setup := NewTestSetup()

		// Generate a random non-existent event ID
		// Using a pattern that won't match the mock repository's ID generation
		nonExistentID := rapid.StringMatching(`nonexistent-[a-z0-9]{8,16}`).Draw(t, "nonExistentID")

		// Test 1: GetEventByID should return "event not found" error
		_, err := setup.Service.GetEventByID(nonExistentID, "")
		if err == nil {
			t.Fatal("GetEventByID should return an error for non-existent ID")
		}
		if err.Error() != "event not found" {
			t.Fatalf("GetEventByID expected error 'event not found', got '%s'", err.Error())
		}

		// Test 2: GetEventByID with userId should also return "event not found" error
		userID := genUserID(t)
		_, err = setup.Service.GetEventByID(nonExistentID, userID)
		if err == nil {
			t.Fatal("GetEventByID with userId should return an error for non-existent ID")
		}
		if err.Error() != "event not found" {
			t.Fatalf("GetEventByID with userId expected error 'event not found', got '%s'", err.Error())
		}

		// Test 3: UpdateEvent should return "event not found" error
		updateEvent := genValidEvent(t)
		_, err = setup.Service.UpdateEvent(nonExistentID, updateEvent)
		if err == nil {
			t.Fatal("UpdateEvent should return an error for non-existent ID")
		}
		if err.Error() != "event not found" {
			t.Fatalf("UpdateEvent expected error 'event not found', got '%s'", err.Error())
		}

		// Test 4: DeleteEvent should return "event not found" error
		err = setup.Service.DeleteEvent(nonExistentID)
		if err == nil {
			t.Fatal("DeleteEvent should return an error for non-existent ID")
		}
		if err.Error() != "event not found" {
			t.Fatalf("DeleteEvent expected error 'event not found', got '%s'", err.Error())
		}
	})
}

// ============================================================================
// Property 4: Create event round-trip
// **Validates: Requirements 2.1**
// ============================================================================

func TestProperty_CreateEventRoundTrip(t *testing.T) {
	rapid.Check(t, func(t *rapid.T) {
		setup := NewTestSetup()

		// Generate a random valid event
		event := genValidEvent(t)

		// Create it via CreateEvent
		created, err := setup.Service.CreateEvent(event)
		if err != nil {
			t.Fatalf("failed to create event: %v", err)
		}

		// The created event must have a non-empty ID
		if created.ID == "" {
			t.Fatal("created event should have a non-empty ID")
		}

		// Retrieve it via GetEventByID using the returned ID
		retrieved, err := setup.Service.GetEventByID(created.ID, "")
		if err != nil {
			t.Fatalf("failed to get event by ID: %v", err)
		}

		// Verify the retrieved event's fields match the original input
		if retrieved.Title != event.Title {
			t.Fatalf("title mismatch: expected %q, got %q", event.Title, retrieved.Title)
		}
		if retrieved.Organizer != event.Organizer {
			t.Fatalf("organizer mismatch: expected %q, got %q", event.Organizer, retrieved.Organizer)
		}
		if retrieved.StartTime != event.StartTime {
			t.Fatalf("startTime mismatch: expected %q, got %q", event.StartTime, retrieved.StartTime)
		}

		// Verify venue
		if retrieved.Venue.Name != event.Venue.Name {
			t.Fatalf("venue name mismatch: expected %q, got %q", event.Venue.Name, retrieved.Venue.Name)
		}
		if retrieved.Venue.Address.Street != event.Venue.Address.Street {
			t.Fatalf("venue street mismatch: expected %q, got %q", event.Venue.Address.Street, retrieved.Venue.Address.Street)
		}
		if retrieved.Venue.Address.City != event.Venue.Address.City {
			t.Fatalf("venue city mismatch: expected %q, got %q", event.Venue.Address.City, retrieved.Venue.Address.City)
		}
		if retrieved.Venue.Address.PostalCode != event.Venue.Address.PostalCode {
			t.Fatalf("venue postalCode mismatch: expected %q, got %q", event.Venue.Address.PostalCode, retrieved.Venue.Address.PostalCode)
		}
		if retrieved.Venue.Address.Country != event.Venue.Address.Country {
			t.Fatalf("venue country mismatch: expected %q, got %q", event.Venue.Address.Country, retrieved.Venue.Address.Country)
		}

		// Verify dances
		if len(retrieved.Dances) != len(event.Dances) {
			t.Fatalf("dances length mismatch: expected %d, got %d", len(event.Dances), len(retrieved.Dances))
		}
		for i, dance := range event.Dances {
			if retrieved.Dances[i] != dance {
				t.Fatalf("dance[%d] mismatch: expected %q, got %q", i, dance, retrieved.Dances[i])
			}
		}

		// Verify optional description
		if event.Description == nil && retrieved.Description != nil {
			t.Fatalf("description mismatch: expected nil, got %q", *retrieved.Description)
		}
		if event.Description != nil {
			if retrieved.Description == nil {
				t.Fatalf("description mismatch: expected %q, got nil", *event.Description)
			}
			if *retrieved.Description != *event.Description {
				t.Fatalf("description mismatch: expected %q, got %q", *event.Description, *retrieved.Description)
			}
		}

		// Verify optional endTime
		if event.EndTime == nil && retrieved.EndTime != nil {
			t.Fatalf("endTime mismatch: expected nil, got %q", *retrieved.EndTime)
		}
		if event.EndTime != nil {
			if retrieved.EndTime == nil {
				t.Fatalf("endTime mismatch: expected %q, got nil", *event.EndTime)
			}
			if *retrieved.EndTime != *event.EndTime {
				t.Fatalf("endTime mismatch: expected %q, got %q", *event.EndTime, *retrieved.EndTime)
			}
		}

		// Verify optional venue description
		if event.Venue.Description == nil && retrieved.Venue.Description != nil {
			t.Fatalf("venue description mismatch: expected nil, got %q", *retrieved.Venue.Description)
		}
		if event.Venue.Description != nil {
			if retrieved.Venue.Description == nil {
				t.Fatalf("venue description mismatch: expected %q, got nil", *event.Venue.Description)
			}
			if *retrieved.Venue.Description != *event.Venue.Description {
				t.Fatalf("venue description mismatch: expected %q, got %q", *event.Venue.Description, *retrieved.Venue.Description)
			}
		}
	})
}



// ============================================================================
// Property 5: Missing required fields returns 400
// **Validates: Requirements 2.2, 3.3**
//
// NOTE: Validation for required fields happens at the handler layer via Gin's
// binding tags, not at the service layer. The TestEventService doesn't validate
// required fields - it just passes data through.
//
// This test verifies that the CreateEventRequest struct has the correct
// binding:"required" tags on all required fields. The actual HTTP 400 response
// is tested at the handler level using httptest.
// ============================================================================

func TestProperty_MissingRequiredFieldsValidation(t *testing.T) {
	// This test uses reflection to verify that CreateEventRequest has the
	// correct binding tags for required field validation.
	//
	// Required fields per Requirements 2.2 and 3.3:
	// - title
	// - organizer
	// - venue
	// - startTime
	// - dances (with min=1)

	t.Run("CreateEventRequest has correct binding tags", func(t *testing.T) {
		req := models.CreateEventRequest{}
		reqType := reflect.TypeOf(req)

		// Define expected required fields and their binding tags
		expectedBindings := map[string]string{
			"Title":     "required",
			"Organizer": "required",
			"Venue":     "required",
			"StartTime": "required",
			"Dances":    "required,min=1",
		}

		for fieldName, expectedBinding := range expectedBindings {
			field, found := reqType.FieldByName(fieldName)
			if !found {
				t.Fatalf("field %q not found in CreateEventRequest", fieldName)
			}

			bindingTag := field.Tag.Get("binding")
			if bindingTag != expectedBinding {
				t.Fatalf("field %q: expected binding tag %q, got %q", fieldName, expectedBinding, bindingTag)
			}
		}
	})

	t.Run("Optional fields do not have required binding", func(t *testing.T) {
		req := models.CreateEventRequest{}
		reqType := reflect.TypeOf(req)

		// Optional fields should NOT have "required" in their binding tag
		optionalFields := []string{"Description", "EndTime", "Duration", "Info", "Parts"}

		for _, fieldName := range optionalFields {
			field, found := reqType.FieldByName(fieldName)
			if !found {
				t.Fatalf("field %q not found in CreateEventRequest", fieldName)
			}

			bindingTag := field.Tag.Get("binding")
			if strings.Contains(bindingTag, "required") {
				t.Fatalf("optional field %q should not have 'required' in binding tag, got %q", fieldName, bindingTag)
			}
		}
	})

	// Property-based test: Generate events with missing required fields
	// and verify the struct correctly identifies what's missing via reflection
	rapid.Check(t, func(rt *rapid.T) {
		// Randomly decide which required field to omit
		requiredFields := []string{"Title", "Organizer", "Venue", "StartTime", "Dances"}
		fieldToOmit := rapid.SampledFrom(requiredFields).Draw(rt, "fieldToOmit")

		// Create a request with the specified field missing/empty
		req := genValidCreateRequest(rt)

		// Set the chosen field to its zero value
		switch fieldToOmit {
		case "Title":
			req.Title = ""
		case "Organizer":
			req.Organizer = ""
		case "Venue":
			req.Venue = models.Venue{} // Zero value
		case "StartTime":
			req.StartTime = ""
		case "Dances":
			req.Dances = []string{} // Empty slice (violates min=1)
		}

		// Verify via reflection that the field is indeed marked as required
		reqType := reflect.TypeOf(*req)
		field, found := reqType.FieldByName(fieldToOmit)
		if !found {
			rt.Fatalf("field %q not found", fieldToOmit)
		}

		bindingTag := field.Tag.Get("binding")
		if !strings.Contains(bindingTag, "required") {
			rt.Fatalf("field %q should have 'required' in binding tag, got %q", fieldToOmit, bindingTag)
		}

		// NOTE: The actual validation and 400 response is handled by Gin's
		// ShouldBindJSON at the handler layer. This test confirms the struct
		// is correctly annotated for that validation to work.
	})
}

// ============================================================================
// Property 6: Created event IDs are unique
// **Validates: Requirements 2.3**
//
// For any sequence of valid create requests to POST /api/events, all returned
// event IDs should be distinct.
// ============================================================================

func TestProperty_CreatedEventIDsAreUnique(t *testing.T) {
	rapid.Check(t, func(rt *rapid.T) {
		setup := NewTestSetup()

		// Generate a random count of events to create (between 2 and 20)
		eventCount := rapid.IntRange(2, 20).Draw(rt, "eventCount")

		// Collect all returned IDs
		ids := make([]string, 0, eventCount)

		// Create multiple events
		for i := 0; i < eventCount; i++ {
			event := genValidEvent(rt)
			created, err := setup.Service.CreateEvent(event)
			if err != nil {
				rt.Fatalf("failed to create event %d: %v", i, err)
			}

			if created.ID == "" {
				rt.Fatalf("event %d has empty ID", i)
			}

			ids = append(ids, created.ID)
		}

		// Verify all IDs are distinct (no duplicates)
		seen := make(map[string]int)
		for i, id := range ids {
			if prevIndex, exists := seen[id]; exists {
				rt.Fatalf("duplicate ID %q found: event %d and event %d have the same ID", id, prevIndex, i)
			}
			seen[id] = i
		}

		// Additional verification: count of unique IDs equals count of created events
		if len(seen) != eventCount {
			rt.Fatalf("expected %d unique IDs, got %d", eventCount, len(seen))
		}
	})
}

// ============================================================================
// Property 7: Update event round-trip
// **Validates: Requirements 3.1**
//
// For any existing event and any valid update payload, a PUT request to
// /api/events/{id} followed by a GET request to the same ID should return
// an event whose fields match the update payload.
// ============================================================================

func TestProperty_UpdateEventRoundTrip(t *testing.T) {
	rapid.Check(t, func(t *rapid.T) {
		setup := NewTestSetup()

		// Step 1: Create an event using the test service
		originalEvent := genValidEvent(t)
		created, err := setup.Service.CreateEvent(originalEvent)
		if err != nil {
			t.Fatalf("failed to create event: %v", err)
		}
		if created.ID == "" {
			t.Fatal("created event should have a non-empty ID")
		}

		// Step 2: Generate a new random event payload (different from the original)
		updatePayload := genValidEvent(t)

		// Step 3: Update the event using UpdateEvent with the new payload
		updated, err := setup.Service.UpdateEvent(created.ID, updatePayload)
		if err != nil {
			t.Fatalf("failed to update event: %v", err)
		}

		// The updated event should retain the same ID
		if updated.ID != created.ID {
			t.Fatalf("updated event ID mismatch: expected %q, got %q", created.ID, updated.ID)
		}

		// Step 4: Retrieve the event via GetEventByID
		retrieved, err := setup.Service.GetEventByID(created.ID, "")
		if err != nil {
			t.Fatalf("failed to get event by ID after update: %v", err)
		}

		// Step 5: Verify the retrieved event's fields match the UPDATE payload (not the original)
		if retrieved.Title != updatePayload.Title {
			t.Fatalf("title mismatch: expected %q, got %q", updatePayload.Title, retrieved.Title)
		}
		if retrieved.Organizer != updatePayload.Organizer {
			t.Fatalf("organizer mismatch: expected %q, got %q", updatePayload.Organizer, retrieved.Organizer)
		}
		if retrieved.StartTime != updatePayload.StartTime {
			t.Fatalf("startTime mismatch: expected %q, got %q", updatePayload.StartTime, retrieved.StartTime)
		}

		// Verify venue
		if retrieved.Venue.Name != updatePayload.Venue.Name {
			t.Fatalf("venue name mismatch: expected %q, got %q", updatePayload.Venue.Name, retrieved.Venue.Name)
		}
		if retrieved.Venue.Address.Street != updatePayload.Venue.Address.Street {
			t.Fatalf("venue street mismatch: expected %q, got %q", updatePayload.Venue.Address.Street, retrieved.Venue.Address.Street)
		}
		if retrieved.Venue.Address.City != updatePayload.Venue.Address.City {
			t.Fatalf("venue city mismatch: expected %q, got %q", updatePayload.Venue.Address.City, retrieved.Venue.Address.City)
		}
		if retrieved.Venue.Address.PostalCode != updatePayload.Venue.Address.PostalCode {
			t.Fatalf("venue postalCode mismatch: expected %q, got %q", updatePayload.Venue.Address.PostalCode, retrieved.Venue.Address.PostalCode)
		}
		if retrieved.Venue.Address.Country != updatePayload.Venue.Address.Country {
			t.Fatalf("venue country mismatch: expected %q, got %q", updatePayload.Venue.Address.Country, retrieved.Venue.Address.Country)
		}

		// Verify dances
		if len(retrieved.Dances) != len(updatePayload.Dances) {
			t.Fatalf("dances length mismatch: expected %d, got %d", len(updatePayload.Dances), len(retrieved.Dances))
		}
		for i, dance := range updatePayload.Dances {
			if retrieved.Dances[i] != dance {
				t.Fatalf("dance[%d] mismatch: expected %q, got %q", i, dance, retrieved.Dances[i])
			}
		}

		// Verify optional description
		if updatePayload.Description == nil && retrieved.Description != nil {
			t.Fatalf("description mismatch: expected nil, got %q", *retrieved.Description)
		}
		if updatePayload.Description != nil {
			if retrieved.Description == nil {
				t.Fatalf("description mismatch: expected %q, got nil", *updatePayload.Description)
			}
			if *retrieved.Description != *updatePayload.Description {
				t.Fatalf("description mismatch: expected %q, got %q", *updatePayload.Description, *retrieved.Description)
			}
		}

		// Verify optional endTime
		if updatePayload.EndTime == nil && retrieved.EndTime != nil {
			t.Fatalf("endTime mismatch: expected nil, got %q", *retrieved.EndTime)
		}
		if updatePayload.EndTime != nil {
			if retrieved.EndTime == nil {
				t.Fatalf("endTime mismatch: expected %q, got nil", *updatePayload.EndTime)
			}
			if *retrieved.EndTime != *updatePayload.EndTime {
				t.Fatalf("endTime mismatch: expected %q, got %q", *updatePayload.EndTime, *retrieved.EndTime)
			}
		}

		// Verify optional venue description
		if updatePayload.Venue.Description == nil && retrieved.Venue.Description != nil {
			t.Fatalf("venue description mismatch: expected nil, got %q", *retrieved.Venue.Description)
		}
		if updatePayload.Venue.Description != nil {
			if retrieved.Venue.Description == nil {
				t.Fatalf("venue description mismatch: expected %q, got nil", *updatePayload.Venue.Description)
			}
			if *retrieved.Venue.Description != *updatePayload.Venue.Description {
				t.Fatalf("venue description mismatch: expected %q, got %q", *updatePayload.Venue.Description, *retrieved.Venue.Description)
			}
		}
	})
}

// ============================================================================
// Property 8: Delete removes event
// **Validates: Requirements 4.1**
//
// For any existing event, a DELETE request to /api/events/{id} should succeed,
// and a subsequent GET request to the same ID should return "event not found" error.
// ============================================================================

func TestProperty_DeleteRemovesEvent(t *testing.T) {
	rapid.Check(t, func(t *rapid.T) {
		setup := NewTestSetup()

		// Step 1: Create an event using the test service
		event := genValidEvent(t)
		created, err := setup.Service.CreateEvent(event)
		if err != nil {
			t.Fatalf("failed to create event: %v", err)
		}
		if created.ID == "" {
			t.Fatal("created event should have a non-empty ID")
		}

		// Step 2: Verify the event can be retrieved (exists)
		retrieved, err := setup.Service.GetEventByID(created.ID, "")
		if err != nil {
			t.Fatalf("failed to get event after creation: %v", err)
		}
		if retrieved.ID != created.ID {
			t.Fatalf("retrieved event ID mismatch: expected %q, got %q", created.ID, retrieved.ID)
		}

		// Step 3: Delete the event using DeleteEvent
		err = setup.Service.DeleteEvent(created.ID)
		if err != nil {
			t.Fatalf("failed to delete event: %v", err)
		}

		// Step 4: Verify GetEventByID now returns "event not found" error
		_, err = setup.Service.GetEventByID(created.ID, "")
		if err == nil {
			t.Fatal("GetEventByID should return an error after event is deleted")
		}
		if err.Error() != "event not found" {
			t.Fatalf("expected error 'event not found', got '%s'", err.Error())
		}
	})
}

// ============================================================================
// Property 9: Delete cascades to favorites
// **Validates: Requirements 4.3**
//
// For any event that has been favorited by one or more users, deleting that
// event should also remove it from all users' favorites collections. After
// deletion, no user's favorites list should contain the deleted event ID.
// ============================================================================

func TestProperty_DeleteCascadesToFavorites(t *testing.T) {
	rapid.Check(t, func(t *rapid.T) {
		setup := NewTestSetup()

		// Step 1: Create an event using the test service
		event := genValidEvent(t)
		created, err := setup.Service.CreateEvent(event)
		if err != nil {
			t.Fatalf("failed to create event: %v", err)
		}
		if created.ID == "" {
			t.Fatal("created event should have a non-empty ID")
		}

		// Step 2: Add the event to favorites for 1-5 random users
		userCount := rapid.IntRange(1, 5).Draw(t, "userCount")
		userIDs := make([]string, userCount)
		for i := 0; i < userCount; i++ {
			userIDs[i] = genUserID(t)
			err := setup.Service.AddFavorite(userIDs[i], created.ID)
			if err != nil {
				t.Fatalf("failed to add favorite for user %q: %v", userIDs[i], err)
			}
		}

		// Step 3: Verify the favorites exist using HasFavorite
		for _, userID := range userIDs {
			if !setup.FavoritesRepo.HasFavorite(userID, created.ID) {
				t.Fatalf("expected user %q to have event %q in favorites before deletion", userID, created.ID)
			}
		}

		// Step 4: Delete the event using DeleteEvent
		err = setup.Service.DeleteEvent(created.ID)
		if err != nil {
			t.Fatalf("failed to delete event: %v", err)
		}

		// Step 5: Verify that NO user's favorites contain the deleted event ID
		for _, userID := range userIDs {
			if setup.FavoritesRepo.HasFavorite(userID, created.ID) {
				t.Fatalf("user %q should NOT have event %q in favorites after deletion", userID, created.ID)
			}
		}
	})
}

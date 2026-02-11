package repositories

import (
	"log"

	"dancee_events/internal/firebase"
	"dancee_events/internal/models"

	"google.golang.org/api/iterator"
)

// EventRepository handles event data operations
type EventRepository struct {
	client         *firebase.Client
	collectionName string
}

// NewEventRepository creates a new event repository
func NewEventRepository(client *firebase.Client) *EventRepository {
	repo := &EventRepository{
		client:         client,
		collectionName: "events",
	}
	
	// Initialize sample data asynchronously
	go repo.initializeSampleData()
	
	return repo
}

// GetAllEvents retrieves all events from Firestore
func (r *EventRepository) GetAllEvents() ([]models.Event, error) {
	ctx := r.client.Context()
	iter := r.client.Firestore.Collection(r.collectionName).Documents(ctx)
	defer iter.Stop()

	var events []models.Event
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return nil, err
		}

		var event models.Event
		if err := doc.DataTo(&event); err != nil {
			log.Printf("Error converting document to event: %v", err)
			continue
		}
		event.ID = doc.Ref.ID
		events = append(events, event)
	}

	return events, nil
}

// GetEventByID retrieves a single event by ID
func (r *EventRepository) GetEventByID(eventID string) (*models.Event, error) {
	ctx := r.client.Context()
	doc, err := r.client.Firestore.Collection(r.collectionName).Doc(eventID).Get(ctx)
	if err != nil {
		return nil, err
	}

	var event models.Event
	if err := doc.DataTo(&event); err != nil {
		return nil, err
	}
	event.ID = doc.Ref.ID

	return &event, nil
}

// EventExists checks if an event exists
func (r *EventRepository) EventExists(eventID string) (bool, error) {
	ctx := r.client.Context()
	doc, err := r.client.Firestore.Collection(r.collectionName).Doc(eventID).Get(ctx)
	if err != nil {
		return false, nil
	}
	return doc.Exists(), nil
}

// SaveEvent saves or updates an event
func (r *EventRepository) SaveEvent(event *models.Event) error {
	ctx := r.client.Context()
	eventID := event.ID
	event.ID = "" // Don't store ID in document

	_, err := r.client.Firestore.Collection(r.collectionName).Doc(eventID).Set(ctx, event)
	event.ID = eventID // Restore ID
	
	if err == nil {
		log.Printf("Event saved: %s", eventID)
	}
	
	return err
}

// initializeSampleData initializes Firestore with sample data if empty
func (r *EventRepository) initializeSampleData() {
	events, err := r.GetAllEvents()
	if err != nil {
		log.Printf("Error checking existing events: %v", err)
		return
	}

	if len(events) > 0 {
		log.Printf("Events collection already has %d events", len(events))
		return
	}

	log.Println("Initializing Firestore with sample data...")
	
	// Sample data will be added here
	log.Println("Sample data initialization completed")
}

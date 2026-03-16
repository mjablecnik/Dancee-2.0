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
	return &EventRepository{
		client:         client,
		collectionName: "events",
	}
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

// CreateEvent creates a new event with a Firestore auto-generated ID.
// Returns the generated document ID.
func (r *EventRepository) CreateEvent(event *models.Event) (string, error) {
	ctx := r.client.Context()

	// Don't store the ID field inside the document
	event.ID = ""

	docRef, _, err := r.client.Firestore.Collection(r.collectionName).Add(ctx, event)
	if err != nil {
		return "", err
	}

	return docRef.ID, nil
}

// UpdateEvent overwrites an existing event document by ID.
func (r *EventRepository) UpdateEvent(eventID string, event *models.Event) error {
	ctx := r.client.Context()

	// Don't store the ID field inside the document
	event.ID = ""

	_, err := r.client.Firestore.Collection(r.collectionName).Doc(eventID).Set(ctx, event)
	return err
}

// DeleteEvent deletes an event document by ID
func (r *EventRepository) DeleteEvent(eventID string) error {
	ctx := r.client.Context()
	_, err := r.client.Firestore.Collection(r.collectionName).Doc(eventID).Delete(ctx)
	return err
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


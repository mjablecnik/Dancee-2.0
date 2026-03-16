package repositories

import (
	"log"

	"dancee_events/internal/firebase"
	"dancee_events/internal/models"

	"google.golang.org/api/iterator"
)

// FavoritesRepository handles user favorites operations
type FavoritesRepository struct {
	client         *firebase.Client
	collectionName string
}

// NewFavoritesRepository creates a new favorites repository
func NewFavoritesRepository(client *firebase.Client) *FavoritesRepository {
	return &FavoritesRepository{
		client:         client,
		collectionName: "favorites",
	}
}

// GetFavorites retrieves all favorite events for a user
func (r *FavoritesRepository) GetFavorites(userID string) ([]models.Event, error) {
	ctx := r.client.Context()
	iter := r.client.Firestore.
		Collection(r.collectionName).
		Doc(userID).
		Collection("events").
		Documents(ctx)
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

// AddFavorite adds an event to user's favorites
func (r *FavoritesRepository) AddFavorite(userID string, event *models.Event) error {
	ctx := r.client.Context()
	eventID := event.ID
	event.ID = "" // Don't store ID in document

	_, err := r.client.Firestore.
		Collection(r.collectionName).
		Doc(userID).
		Collection("events").
		Doc(eventID).
		Set(ctx, event)
	
	event.ID = eventID // Restore ID
	
	if err == nil {
		log.Printf("Added favorite for user %s: %s", userID, eventID)
	}
	
	return err
}

// RemoveFavorite removes an event from user's favorites
func (r *FavoritesRepository) RemoveFavorite(userID, eventID string) error {
	ctx := r.client.Context()
	_, err := r.client.Firestore.
		Collection(r.collectionName).
		Doc(userID).
		Collection("events").
		Doc(eventID).
		Delete(ctx)
	
	if err == nil {
		log.Printf("Removed favorite for user %s: %s", userID, eventID)
	}
	
	return err
}

// RemoveFavoritesByEventID removes a specific event from all users' favorites.
// Queries all user documents in the favorites collection and deletes the
// matching event sub-document for each user.
func (r *FavoritesRepository) RemoveFavoritesByEventID(eventID string) error {
	ctx := r.client.Context()
	iter := r.client.Firestore.
		Collection(r.collectionName).
		Documents(ctx)
	defer iter.Stop()

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return err
		}

		userID := doc.Ref.ID
		_, err = r.client.Firestore.
			Collection(r.collectionName).
			Doc(userID).
			Collection("events").
			Doc(eventID).
			Delete(ctx)
		if err != nil {
			log.Printf("Error removing favorite event %s for user %s: %v", eventID, userID, err)
		}
	}

	log.Printf("Removed event %s from all users' favorites", eventID)
	return nil
}


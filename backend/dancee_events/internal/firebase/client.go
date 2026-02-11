package firebase

import (
	"context"
	"encoding/json"
	"log"

	"dancee_events/internal/config"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"google.golang.org/api/option"
)

// Client wraps Firebase and Firestore clients
type Client struct {
	App       *firebase.App
	Firestore *firestore.Client
	ctx       context.Context
}

// NewClient creates a new Firebase client
func NewClient(cfg *config.Config) (*Client, error) {
	ctx := context.Background()

	var opts []option.ClientOption

	// Priority: JSON string > file path > application default credentials
	if cfg.FirebaseServiceAccountJSON != "" {
		log.Println("Loading Firebase service account from environment variable")
		opts = append(opts, option.WithCredentialsJSON([]byte(cfg.FirebaseServiceAccountJSON)))
	} else if cfg.FirebaseServiceAccountPath != "" {
		log.Printf("Loading Firebase service account from: %s", cfg.FirebaseServiceAccountPath)
		opts = append(opts, option.WithCredentialsFile(cfg.FirebaseServiceAccountPath))
	} else {
		log.Println("Using application default credentials")
	}

	// Configure Firebase with project ID
	firebaseConfig := &firebase.Config{
		ProjectID: cfg.GoogleCloudProject,
	}

	// Initialize Firebase app
	app, err := firebase.NewApp(ctx, firebaseConfig, opts...)
	if err != nil {
		return nil, err
	}

	// Initialize Firestore client
	firestoreClient, err := app.Firestore(ctx)
	if err != nil {
		return nil, err
	}

	log.Println("Firebase and Firestore initialized successfully")

	return &Client{
		App:       app,
		Firestore: firestoreClient,
		ctx:       ctx,
	}, nil
}

// Close closes the Firestore client
func (c *Client) Close() error {
	if c.Firestore != nil {
		return c.Firestore.Close()
	}
	return nil
}

// Context returns the context
func (c *Client) Context() context.Context {
	return c.ctx
}

// Helper function to convert map to struct
func MapToStruct(data map[string]interface{}, result interface{}) error {
	jsonData, err := json.Marshal(data)
	if err != nil {
		return err
	}
	return json.Unmarshal(jsonData, result)
}

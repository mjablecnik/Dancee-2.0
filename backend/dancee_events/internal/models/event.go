package models

// Address represents a physical address
type Address struct {
	Street     string `json:"street" firestore:"street"`
	City       string `json:"city" firestore:"city"`
	PostalCode string `json:"postalCode" firestore:"postalCode"`
	Country    string `json:"country" firestore:"country"`
}

// Venue represents an event venue
type Venue struct {
	Name        string   `json:"name" firestore:"name"`
	Address     Address  `json:"address" firestore:"address"`
	Description *string  `json:"description,omitempty" firestore:"description,omitempty"`
	Latitude    *float64 `json:"latitude,omitempty" firestore:"latitude,omitempty"`
	Longitude   *float64 `json:"longitude,omitempty" firestore:"longitude,omitempty"`
}

// EventInfo represents additional event information
type EventInfo struct {
	Type  string `json:"type" firestore:"type"`
	Key   string `json:"key" firestore:"key"`
	Value string `json:"value" firestore:"value"`
}

// EventPart represents a part/segment of an event
type EventPart struct {
	Name        string   `json:"name" firestore:"name"`
	Description *string  `json:"description,omitempty" firestore:"description,omitempty"`
	Type        string   `json:"type" firestore:"type"`
	StartTime   string   `json:"startTime" firestore:"startTime"`
	EndTime     *string  `json:"endTime,omitempty" firestore:"endTime,omitempty"`
	DJs         []string `json:"djs,omitempty" firestore:"djs,omitempty"`
	Lectors     []string `json:"lectors,omitempty" firestore:"lectors,omitempty"`
}

// Event represents a dance event
type Event struct {
	ID          string       `json:"id" firestore:"-"`
	Title       string       `json:"title" firestore:"title"`
	Description *string      `json:"description,omitempty" firestore:"description,omitempty"`
	Organizer   string       `json:"organizer" firestore:"organizer"`
	Venue       Venue        `json:"venue" firestore:"venue"`
	StartTime   string       `json:"startTime" firestore:"startTime"`
	EndTime     *string      `json:"endTime,omitempty" firestore:"endTime,omitempty"`
	Duration    *int64       `json:"duration,omitempty" firestore:"duration,omitempty"`
	Dances      []string     `json:"dances" firestore:"dances"`
	Info        []EventInfo  `json:"info,omitempty" firestore:"info,omitempty"`
	Parts       []EventPart  `json:"parts,omitempty" firestore:"parts,omitempty"`
	IsFavorite  *bool        `json:"isFavorite,omitempty" firestore:"isFavorite,omitempty"`
	IsPast      *bool        `json:"isPast,omitempty" firestore:"-"`
}

// AddFavoriteRequest represents the request to add a favorite
type AddFavoriteRequest struct {
	UserID  string `json:"userId" binding:"required"`
	EventID string `json:"eventId" binding:"required"`
}

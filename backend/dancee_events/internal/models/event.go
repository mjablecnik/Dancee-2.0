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
	Description string  `json:"description" firestore:"description"`
	Latitude    float64 `json:"latitude" firestore:"latitude"`
	Longitude   float64 `json:"longitude" firestore:"longitude"`
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
	Description string       `json:"description" firestore:"description"`
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

// CreateEventRequest represents the request body for creating/updating an event.
// Uses Gin's binding tags for required field validation.
type CreateEventRequest struct {
	Title       string      `json:"title" binding:"required"`
	Description string      `json:"description" binding:"required"`
	Organizer   string      `json:"organizer" binding:"required"`
	Venue       Venue       `json:"venue" binding:"required"`
	StartTime   string      `json:"startTime" binding:"required"`
	EndTime     *string     `json:"endTime,omitempty"`
	Duration    *int64      `json:"duration,omitempty"`
	Dances      []string    `json:"dances" binding:"required,min=1"`
	Info        []EventInfo `json:"info,omitempty"`
	Parts       []EventPart `json:"parts,omitempty"`
}

// ToEvent converts a CreateEventRequest to an Event model.
func (r *CreateEventRequest) ToEvent() *Event {
	return &Event{
		Title:       r.Title,
		Description: r.Description,
		Organizer:   r.Organizer,
		Venue:       r.Venue,
		StartTime:   r.StartTime,
		EndTime:     r.EndTime,
		Duration:    r.Duration,
		Dances:      r.Dances,
		Info:        r.Info,
		Parts:       r.Parts,
	}
}
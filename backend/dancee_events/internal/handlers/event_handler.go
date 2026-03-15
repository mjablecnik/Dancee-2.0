package handlers

import (
	"net/http"

	"dancee_events/internal/models"
	"dancee_events/internal/services"

	"github.com/gin-gonic/gin"
)

// EventHandler handles HTTP requests for events
type EventHandler struct {
	service *services.EventService
}

// NewEventHandler creates a new event handler
func NewEventHandler(service *services.EventService) *EventHandler {
	return &EventHandler{
		service: service,
	}
}

// ListEvents handles GET /api/events/list
func (h *EventHandler) ListEvents(c *gin.Context) {
	userID := c.Query("userId")

	events, err := h.service.GetAllEvents(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, events)
}

// ListFavorites handles GET /api/events/favorites
func (h *EventHandler) ListFavorites(c *gin.Context) {
	userID := c.Query("userId")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "userId query parameter is required"})
		return
	}

	events, err := h.service.GetFavorites(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, events)
}

// AddFavorite handles POST /api/events/favorites
func (h *EventHandler) AddFavorite(c *gin.Context) {
	var req models.AddFavoriteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "userId and eventId are required"})
		return
	}

	if err := h.service.AddFavorite(req.UserID, req.EventID); err != nil {
		if err.Error() == "event not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Event not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Favorite added successfully",
		"userId":  req.UserID,
		"eventId": req.EventID,
	})
}

// RemoveFavorite handles DELETE /api/events/favorites/:eventId
func (h *EventHandler) RemoveFavorite(c *gin.Context) {
	eventID := c.Param("eventId")
	userID := c.Query("userId")

	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "userId query parameter is required"})
		return
	}

	if err := h.service.RemoveFavorite(userID, eventID); err != nil {
		if err.Error() == "event not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Event not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Status(http.StatusNoContent)
}

// SeedEvents handles POST /api/events/seed
// TODO: Remove this endpoint once Facebook event scraping is fully implemented.
func (h *EventHandler) SeedEvents(c *gin.Context) {
	events, err := h.service.SeedEvents()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Successfully seeded events",
		"count":   len(events),
		"events":  events,
	})
}

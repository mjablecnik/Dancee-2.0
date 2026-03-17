package main

import (
	"log"
	"os"

	"dancee_events/internal/config"
	"dancee_events/internal/firebase"
	"dancee_events/internal/handlers"
	"dancee_events/internal/repositories"
	"dancee_events/internal/services"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	// Load configuration
	cfg := config.Load()

	// Initialize Firebase
	firebaseClient, err := firebase.NewClient(cfg)
	if err != nil {
		log.Fatalf("Failed to initialize Firebase: %v", err)
	}
	defer firebaseClient.Close()

	// Initialize repositories
	eventRepo := repositories.NewEventRepository(firebaseClient)
	favoritesRepo := repositories.NewFavoritesRepository(firebaseClient)

	// Initialize services
	eventService := services.NewEventService(eventRepo, favoritesRepo)

	// Initialize handlers
	eventHandler := handlers.NewEventHandler(eventService)

	// Setup router
	if cfg.Env == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.Default()

	// CORS middleware
	router.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// Register event routes (with /api prefix)
	registerEventRoutes := func(group *gin.RouterGroup) {
		events := group.Group("/events")
		{
			events.GET("/list", eventHandler.ListEvents)
			events.GET("/favorites", eventHandler.ListFavorites)
			events.POST("/favorites", eventHandler.AddFavorite)
			events.DELETE("/favorites/:eventId", eventHandler.RemoveFavorite)
			events.GET("/:id", eventHandler.GetEvent)
			events.POST("", eventHandler.CreateEvent)
			events.PUT("/:id", eventHandler.UpdateEvent)
			events.DELETE("/:id", eventHandler.DeleteEvent)
		}
	}

	// API routes with /api prefix
	api := router.Group("/api")
	registerEventRoutes(api)

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Starting server on port %s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

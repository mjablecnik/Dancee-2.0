package config

import "os"

// Config holds application configuration
type Config struct {
	Port                       string
	Env                        string
	FirebaseServiceAccountPath string
	FirebaseServiceAccountJSON string
	GoogleCloudProject         string
}

// Load loads configuration from environment variables
func Load() *Config {
	return &Config{
		Port:                       getEnv("PORT", "8080"),
		Env:                        getEnv("ENV", "development"),
		FirebaseServiceAccountPath: os.Getenv("FIREBASE_SERVICE_ACCOUNT_PATH"),
		FirebaseServiceAccountJSON: os.Getenv("FIREBASE_SERVICE_ACCOUNT_JSON"),
		GoogleCloudProject:         getEnv("GOOGLE_CLOUD_PROJECT", "dancee-b5c0d"),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

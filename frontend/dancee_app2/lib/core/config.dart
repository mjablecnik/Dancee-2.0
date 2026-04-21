// Re-exports sensitive CMS config values and defines public app constants.
// Import this file throughout the app instead of importing lib/config.dart directly.

export '../config.dart' show directusBaseUrl, directusAccessToken;

/// Default user ID used for favorites operations (auth is out of scope).
const String defaultUserId = 'default-user';

/// HTTP connection timeout in milliseconds.
const int connectionTimeoutMs = 10000;

/// HTTP receive timeout in milliseconds.
const int receiveTimeoutMs = 15000;

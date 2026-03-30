import { reverseGeocode } from "../clients/nominatim-client";
import {
  createVenue,
  findVenue,
  findVenueByCoordinates,
} from "../clients/directus-client";
import type { FacebookLocation, DirectusVenue } from "../core/schemas";
import { log } from "../core/logger";

export async function resolveVenue(location: FacebookLocation): Promise<DirectusVenue | null> {
  const lat = location.latitude;
  const lng = location.longitude;

  // Check existing venue by coordinates first
  if (lat !== undefined && lng !== undefined) {
    const byCoords = await findVenueByCoordinates(lat, lng);
    if (byCoords) return byCoords;
  }

  // Build venue fields from Facebook location data
  let name = location.name ?? "";
  let street = location.address ?? "";
  let town = location.city ?? "";
  // Use countryCode if available (ISO alpha-2), fall back to country name
  let country = location.countryCode ?? location.country ?? "";
  let region = "Other";
  let postalCode: string | undefined;
  let houseNumber: string | undefined;

  // Check existing venue by (name, street, town) BEFORE calling Nominatim
  // (Requirement 6.8: avoid unnecessary external geocoding requests)
  if (name && street && town) {
    const byFields = await findVenue(name, street, town);
    if (byFields) return byFields;
  }

  // Call Nominatim when coordinates are available to supplement region and
  // fill in any missing fields (requirement 6.2). Per the design error handling
  // table, a Nominatim failure falls back to region "Other" so the workflow
  // is not blocked by a non-critical geocoding outage or rate limit.
  if (lat !== undefined && lng !== undefined) {
    try {
      const geo = await reverseGeocode(lat, lng);
      const addr = geo.address ?? {};
      // Fill in only missing fields from Nominatim; region always comes from Nominatim
      name = name || addr.road || "";
      street = street || addr.road || "";
      houseNumber = addr.house_number;
      town = town || addr.city || addr.town || addr.village || addr.county || "";
      country = country || addr.country_code?.toUpperCase() || "";
      postalCode = addr.postcode;
      region = addr.state ?? "Other";
    } catch (err) {
      log({ level: "warn", message: `reverseGeocode failed for coordinates (${lat}, ${lng}), falling back to region "Other"`, error: String(err) });
      // region remains "Other" (already initialised above)
    }
  }

  // When all identifying fields are empty, there is nothing meaningful to store.
  // Creating an empty-field venue would pollute the collection with duplicates since
  // the (name, street, town) deduplication check is skipped for empty fields.
  if (!name && !street && !town) {
    log({ level: "warn", message: `resolveVenue: all identifying venue fields are empty for location (${lat ?? "?"}, ${lng ?? "?"}), skipping venue creation` });
    return null;
  }

  const newVenue: DirectusVenue = {
    name,
    street,
    number: houseNumber ?? "",
    town,
    country,
    postal_code: postalCode ?? "",
    region,
    latitude: lat ?? null,
    longitude: lng ?? null,
  };

  return createVenue(newVenue);
}

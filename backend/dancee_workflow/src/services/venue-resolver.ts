import { reverseGeocode } from "../clients/nominatim-client";
import {
  createVenue,
  findVenue,
  findVenueByCoordinates,
} from "../clients/directus-client";
import type { FacebookLocation, DirectusVenue } from "../core/schemas";

export async function resolveVenue(location: FacebookLocation): Promise<DirectusVenue> {
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
  let country = location.countryCode ?? "";
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
  // fill in any missing fields (requirement 6.2)
  if (lat !== undefined && lng !== undefined) {
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

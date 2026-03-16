use crate::models::{GooglePlace, PlaceDetails};

const FIELD_MASK: &str = "id,displayName,formattedAddress,nationalPhoneNumber,rating,userRatingCount,businessStatus,currentOpeningHours,regularOpeningHours,googleMapsUri";

pub async fn get_place_details(place_id: &str, api_key: &str) -> Result<PlaceDetails, String> {
    let url = format!("https://places.googleapis.com/v1/places/{place_id}");

    let mut init = worker::RequestInit::new();
    init.with_method(worker::Method::Get);

    let mut headers = worker::Headers::new();
    let _ = headers.set("X-Goog-Api-Key", api_key);
    let _ = headers.set("X-Goog-FieldMask", FIELD_MASK);
    init.with_headers(headers);

    let request = worker::Request::new_with_init(&url, &init)
        .map_err(|e| format!("Failed to create request: {e}"))?;

    let mut response = worker::Fetch::Request(request)
        .send()
        .await
        .map_err(|e| format!("Fetch failed: {e}"))?;

    if response.status_code() != 200 {
        let text = response.text().await.unwrap_or_default();
        return Err(format!(
            "Google API returned {}: {}",
            response.status_code(),
            text
        ));
    }

    let p: GooglePlace = response
        .json()
        .await
        .map_err(|e| format!("Failed to parse response: {e}"))?;

    let hours = p
        .current_opening_hours
        .as_ref()
        .or(p.regular_opening_hours.as_ref());

    Ok(PlaceDetails {
        place_id: p.id.unwrap_or_default(),
        name: p.display_name.map(|d| d.text).unwrap_or_default(),
        address: p.formatted_address.unwrap_or_default(),
        phone: p.national_phone_number,
        rating: p.rating,
        user_rating_count: p.user_rating_count,
        business_status: p.business_status,
        open_now: hours.and_then(|h| h.open_now),
        weekday_hours: hours.and_then(|h| h.weekday_descriptions.clone()),
        google_maps_uri: p.google_maps_uri,
    })
}

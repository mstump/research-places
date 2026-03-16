use serde::{Deserialize, Serialize};

// Clean response types (sent to iOS app)

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PlaceSearchResult {
    pub place_id: String,
    pub name: String,
    pub address: String,
    pub types: Vec<String>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PlaceDetails {
    pub place_id: String,
    pub name: String,
    pub address: String,
    pub phone: Option<String>,
    pub rating: Option<f64>,
    pub user_rating_count: Option<u32>,
    pub business_status: Option<String>,
    pub open_now: Option<bool>,
    pub weekday_hours: Option<Vec<String>>,
    pub google_maps_uri: Option<String>,
}

#[derive(Serialize)]
pub struct ErrorResponse {
    pub error: String,
}

// Google Places API (New) response types

#[derive(Deserialize)]
pub struct GoogleTextSearchResponse {
    pub places: Option<Vec<GooglePlace>>,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct GooglePlace {
    pub id: Option<String>,
    pub display_name: Option<GoogleDisplayName>,
    pub formatted_address: Option<String>,
    pub types: Option<Vec<String>>,
    pub national_phone_number: Option<String>,
    pub rating: Option<f64>,
    pub user_rating_count: Option<u32>,
    pub business_status: Option<String>,
    pub current_opening_hours: Option<GoogleOpeningHours>,
    pub regular_opening_hours: Option<GoogleOpeningHours>,
    pub google_maps_uri: Option<String>,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct GoogleDisplayName {
    pub text: String,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct GoogleOpeningHours {
    pub open_now: Option<bool>,
    pub weekday_descriptions: Option<Vec<String>>,
}

use crate::models::{GoogleTextSearchResponse, PlaceSearchResult};

const FIELD_MASK: &str = "places.id,places.displayName,places.formattedAddress,places.types";

pub async fn search_places(
    query: &str,
    api_key: &str,
) -> Result<Vec<PlaceSearchResult>, String> {
    let body = serde_json::json!({ "textQuery": query });

    let mut init = worker::RequestInit::new();
    init.with_method(worker::Method::Post);
    init.with_body(Some(worker::wasm_bindgen::JsValue::from_str(
        &body.to_string(),
    )));

    let mut headers = worker::Headers::new();
    let _ = headers.set("Content-Type", "application/json");
    let _ = headers.set("X-Goog-Api-Key", api_key);
    let _ = headers.set("X-Goog-FieldMask", FIELD_MASK);
    init.with_headers(headers);

    let request =
        worker::Request::new_with_init("https://places.googleapis.com/v1/places:searchText", &init)
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

    let data: GoogleTextSearchResponse = response
        .json()
        .await
        .map_err(|e| format!("Failed to parse response: {e}"))?;

    let results = data
        .places
        .unwrap_or_default()
        .into_iter()
        .map(|p| PlaceSearchResult {
            place_id: p.id.unwrap_or_default(),
            name: p.display_name.map(|d| d.text).unwrap_or_default(),
            address: p.formatted_address.unwrap_or_default(),
            types: p.types.unwrap_or_default(),
        })
        .collect();

    Ok(results)
}

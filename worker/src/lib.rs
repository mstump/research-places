use worker::*;

mod models;
mod search;
mod place;

fn cors_headers() -> Headers {
    let mut headers = Headers::new();
    let _ = headers.set("Access-Control-Allow-Origin", "*");
    let _ = headers.set("Access-Control-Allow-Methods", "GET, OPTIONS");
    let _ = headers.set("Access-Control-Allow-Headers", "Content-Type");
    headers
}

fn json_response(body: &str, status: u16) -> Result<Response> {
    let mut resp = Response::ok(body)?;
    if status != 200 {
        resp = resp.with_status(status);
    }
    let mut headers = cors_headers();
    let _ = headers.set("Content-Type", "application/json");
    Ok(resp.with_headers(headers))
}

#[event(fetch)]
async fn main(req: Request, env: Env, _ctx: Context) -> Result<Response> {
    if req.method() == Method::Options {
        return Ok(Response::empty()?.with_headers(cors_headers()));
    }

    let path = req.path();
    let url = req.url()?;

    if path.starts_with("/api/search") {
        let query = url
            .query_pairs()
            .find(|(k, _)| k == "query")
            .map(|(_, v)| v.to_string())
            .unwrap_or_default();

        if query.is_empty() {
            return json_response(
                &serde_json::to_string(&models::ErrorResponse {
                    error: "Missing query parameter".into(),
                })?,
                400,
            );
        }

        let api_key = env.secret("GOOGLE_MAPS_API_KEY")?.to_string();
        match search::search_places(&query, &api_key).await {
            Ok(results) => json_response(&serde_json::to_string(&results)?, 200),
            Err(e) => json_response(
                &serde_json::to_string(&models::ErrorResponse {
                    error: format!("Search failed: {e}"),
                })?,
                502,
            ),
        }
    } else if path.starts_with("/api/place/") {
        let place_id = path.strip_prefix("/api/place/").unwrap_or("");
        if place_id.is_empty() {
            return json_response(
                &serde_json::to_string(&models::ErrorResponse {
                    error: "Missing place ID".into(),
                })?,
                400,
            );
        }

        let api_key = env.secret("GOOGLE_MAPS_API_KEY")?.to_string();
        match place::get_place_details(place_id, &api_key).await {
            Ok(details) => json_response(&serde_json::to_string(&details)?, 200),
            Err(e) => json_response(
                &serde_json::to_string(&models::ErrorResponse {
                    error: format!("Place details failed: {e}"),
                })?,
                502,
            ),
        }
    } else {
        json_response(
            &serde_json::to_string(&models::ErrorResponse {
                error: "Not found".into(),
            })?,
            404,
        )
    }
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#[macro_use]
extern crate rocket;

#[macro_use]
extern crate tracing;

use rocket::{
    form::Form,
    fs::{relative, FileServer, TempFile},
    http::Status,
    response::status,
};
use std::env;
use tracing_subscriber::{
    fmt::{format::FmtSpan, time},
    EnvFilter,
};

#[instrument(err(Debug))]
#[post("/upload", data = "<file>")]
async fn upload(file: Form<TempFile<'_>>) -> Result<(), status::Custom<&'static str>> {
    let Some(content_type) = file.content_type() else {
        return Err(status::Custom(Status::BadRequest, "no content-type"));
    };
    if !content_type.is_jpeg() && !content_type.is_png() {
        return Err(status::Custom(
            Status::BadRequest,
            "content-type not supported",
        ));
    }
    info!(
        "uploading '{}' of length {}",
        file.content_type()
            .map_or_else(|| String::from("(unknown content-type)"), |c| c.to_string()),
        file.len()
    );
    Ok(())
}

#[rocket::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let format =
        ::time::format_description::parse("[hour]:[minute]:[second].[subsecond digits:9]")?;
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .with_span_events(FmtSpan::NEW | FmtSpan::CLOSE)
        .with_ansi(env::var("NO_COLOR").map_or(true, |v| v.is_empty()))
        .with_timer(time::LocalTime::new(format))
        .init();

    rocket::build()
        .mount("/api", routes![upload])
        .mount("/", FileServer::from(relative!("static")))
        .launch()
        .await?;
    Ok(())
}

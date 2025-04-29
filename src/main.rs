// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#[macro_use]
extern crate tracing;

#[macro_use]
extern crate rocket;

use rocket::{
    form::Form,
    fs::{relative, FileServer, TempFile},
    http::Status,
    response::status,
};
use tracing::info;

#[launch]
fn rocket() -> _ {
    rocket::build()
        .mount("/api", routes![upload])
        .mount("/", FileServer::from(relative!("static")))
}

#[instrument]
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

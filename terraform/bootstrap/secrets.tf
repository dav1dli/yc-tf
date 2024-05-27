resource "yandex_lockbox_secret" "oauth-token" {
  name        = "oauth-token"
  description = "Yandex OAuth token"
}

resource "yandex_lockbox_secret_version" "oauth-token" {
  secret_id = yandex_lockbox_secret.oauth-token.id
  description = "Initial version"
  entries {
    key         = "token"
    text_value  = var.yc_oauth_token
  }
}

resource "yandex_lockbox_secret" "s3-secret-key" {
  name        = "s3-secret-key"
  description = "Storage bucket secret key"
}

resource "yandex_lockbox_secret_version" "s3-secret-key" {
  secret_id = yandex_lockbox_secret.s3-secret-key.id
  description = "Initial version"
  entries {
    key         = "secret-key"
    text_value  = yandex_storage_bucket.s3tf.secret_key
  }
}
resource "yandex_function" "vvot25-bot" {
  name       = "vvot25-bot"
  user_hash  = data.archive_file.vvot25-bot.output_sha256
  runtime    = "python312"
  entrypoint = "index.handler"
  service_account_id = "${yandex_iam_service_account.sa.id}"
  memory     = 128
  execution_timeout = 30
  environment = {
    "tg_bot_key": var.tg_bot_key,
    "AWS_ACCESS_KEY_ID" = yandex_iam_service_account_static_access_key.sa-static-key.access_key,
    "AWS_SECRET_ACCESS_KEY" = yandex_iam_service_account_static_access_key.sa-static-key.secret_key,
    "api_gw_domain": yandex_api_gateway.api-gw.domain,
  }
  content {
    zip_filename = data.archive_file.vvot25-bot.output_path
  }
  storage_mounts {
    bucket = yandex_storage_bucket.vvot25-photo.bucket
    mount_point_name = var.bucket_photo
  }
  storage_mounts {
    bucket = yandex_storage_bucket.vvot25-faces.bucket
    mount_point_name = var.bucket_face
  }
}


provider "telegram" {
  bot_token = var.tg_bot_key
}

resource "telegram_bot_webhook" "my_bot" {
  url = "https://api.telegram.org/bot${var.tg_bot_key}/setWebhook?url=https://functions.yandexcloud.net/${yandex_function.vvot25-bot.id}"
}


data "archive_file" "vvot25-bot" {
  type        = "zip"
  output_path = "func_bot.zip"
  source_dir  = "/home/ubuntu/face-hw2/func_bot"
}

resource "yandex_function_iam_binding" "function-aim-f-bot" {
  function_id = yandex_function.vvot25-bot.id
  role        = "serverless.functions.invoker"

  members = [
    "system:allUsers"
  ]
}

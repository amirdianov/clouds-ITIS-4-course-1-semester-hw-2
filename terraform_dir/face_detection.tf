resource "yandex_function" "vvot25-face-detection" {
  name       = "vvot25-face-detection"
  user_hash  = data.archive_file.vvot25-face-detection.output_sha256
  runtime    = "python312"
  entrypoint = "index.handler"
  service_account_id = "${yandex_iam_service_account.sa.id}"
  memory     = 256
  execution_timeout = 5
  environment = {
    "AWS_ACCESS_KEY_ID" = yandex_iam_service_account_static_access_key.sa-static-key.access_key,
    "AWS_SECRET_ACCESS_KEY" = yandex_iam_service_account_static_access_key.sa-static-key.secret_key,
  }
  content {
    zip_filename = data.archive_file.vvot25-face-detection.output_path
  }
  storage_mounts {
    bucket = yandex_storage_bucket.vvot25-photo.bucket
    mount_point_name = var.bucket_photo
  }
}

data "archive_file" "vvot25-face-detection" {
  type        = "zip"
  output_path = "func_face_detection.zip"
  source_dir  = "/home/ubuntu/face-hw2/func_face_detection"
}

resource "yandex_function_iam_binding" "function-aim-f-face-detection" {
  function_id = yandex_function.vvot25-face-detection.id
  role        = "serverless.functions.invoker"

  members = [
    "system:allUsers"
  ]
}


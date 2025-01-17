resource "yandex_function" "vvot25-face-cut" {
  name       = "vvot25-face-cut"
  user_hash  = data.archive_file.vvot25-face-cut.output_sha256
  runtime    = "python312"
  entrypoint = "index.handler"
  service_account_id = "${yandex_iam_service_account.sa.id}"
  memory     = 128
  execution_timeout = 30
  environment = {
    "AWS_ACCESS_KEY_ID" = yandex_iam_service_account_static_access_key.sa-static-key.access_key,
    "AWS_SECRET_ACCESS_KEY" = yandex_iam_service_account_static_access_key.sa-static-key.secret_key,
  }
  content {
    zip_filename = data.archive_file.vvot25-face-cut.output_path
  }
  storage_mounts {
    bucket = yandex_storage_bucket.vvot25-photo.bucket
    mount_point_name = var.bucket_photo
  }
}

data "archive_file" "vvot25-face-cut" {
  type        = "zip"
  output_path = "func_face_cut.zip"
  source_dir  = "/home/ubuntu/face-hw2/func_face_cut"
}

resource "yandex_function_iam_binding" "function-aim-f-face-cut" {
  function_id = yandex_function.vvot25-face-cut.id
  role        = "serverless.functions.invoker"

  members = [
    "system:allUsers"
  ]
}

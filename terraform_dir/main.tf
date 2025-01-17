terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    telegram = {
      source = "yi-jiayu/telegram"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = pathexpand("~/yc-keys/key.json")
}

resource "yandex_iam_service_account" "sa" {
  name        = "sa-hw2"
  description = "service account"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-admin" {
  folder_id = var.folder_id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key"
}

resource "yandex_message_queue" "vvot25-task" {
  name = "vvot25-task"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}

resource "yandex_api_gateway" "api-gw" {
  name = "vvot25-apigw"
  spec = <<-EOT
openapi: 3.0.0
info:
  version: 1.0.0
  title: API GW
paths:
  /:
    get:
      summary: API GW
      parameters:
        - name: face
          in: query
          required: true
          schema: 
            type: string

      x-yc-apigateway-integration:
        type: object_storage
        object: '{face}'
        service_account_id: ${yandex_iam_service_account.sa.id} 
        bucket: ${yandex_storage_bucket.vvot25-faces.bucket} 
  /original_photo:
    get:
      summary: Get original photo
      parameters:
        - name: original_photo
          in: query
          required: true
          schema: 
            type: string

      x-yc-apigateway-integration:
        type: object_storage
        object: '{original_photo}'
        service_account_id: ${yandex_iam_service_account.sa.id} 
        bucket: ${yandex_storage_bucket.vvot25-photo.bucket} 
EOT
}

resource "yandex_storage_bucket" "vvot25-photo" {
  bucket = var.bucket_photo
}

resource "yandex_storage_bucket" "vvot25-faces" {
  bucket = var.bucket_face
}


variable "bucket_photo" {
  type        = string
  description = "Бакет оригинальных фотографий"
}

variable "bucket_face" {
  type        = string
  description = "Бакет лиц"
}

variable "cloud_id" {
  type        = string
  description = "Идентификатор облака"
}

variable "folder_id" {
  type        = string
  description = "Идентификатор папки"
}

variable "tg_bot_key" {
  type        = string
  description = "Бот ключ"
}
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
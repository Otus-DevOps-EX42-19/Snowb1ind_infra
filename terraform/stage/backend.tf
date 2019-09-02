terraform {
  backend "gcs" {
    bucket = "storage-bucket-snowb1ind"
    prefix = "stage"
  }
}
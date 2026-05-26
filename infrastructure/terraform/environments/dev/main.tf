terraform {
  required_version = ">= 1.0"
  backend "local" {
    path = "terraform.tfstate"
  }
}

module "s3_bucket" {
  source      = "../../modules/s3"
  bucket_name = "dev-platform-assets"
}

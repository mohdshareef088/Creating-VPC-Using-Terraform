terraform {
  backend "s3" {
    bucket       = "my-tf-testvpc-bucket"
    key          = "terraform.tfstate"
    region       = "ap-southeast-2"
    use_lockfile = true
  }
}
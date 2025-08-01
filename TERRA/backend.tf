terraform {
    backend "s3" {
        bucket         = "dynamic-ansible-inventory-bucket"
        key            = "dev/terraform.tfstate"
        region         = "eu-west-2"
        encrypt        = true
        versioning     = true
        
    }
}
provider "google" {
  version = "~> 3.45.0"
}

provider "null" {
  version = "~> 2.1"
}

locals {
  subnet_01 = "${var.network_name}-subnet-01"
}

module "test-vpc-module" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = var.project_id
  network_name = var.network_name

  subnets = [
    {
      subnet_name   = "${local.subnet_01}"
      subnet_ip     = "10.0.0.0/16"
      subnet_region = "europe-west3"
    }
  ]

  secondary_ranges = {
        "${local.subnet_01}" = [
            {
                range_name    = "subnet-01-pod-cidr-01"
                ip_cidr_range = "192.168.0.0/20"
            },
            {
                range_name    = "subnet-01-service-cidr-01"
                ip_cidr_range = "192.168.32.0/24"
            }
        ]
    }
}
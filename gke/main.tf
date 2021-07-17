locals {
  cluster_type = "simple-zonal"
}

provider "google" {
  version = "~> 3.42.0"
  region  = var.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

/*******************************************
 * Import terraform outputs from VPC  
 ******************************************/
data "terraform_remote_state" "vpc" {
  backend   = "gcs"
  workspace = "default"
  config = {
    bucket = "terraform-tf-state-0000"
    prefix = "vpc/state"
  }
}
/*******************************************
 * GKE Cluster
 ******************************************/

module "gke" {
  source                      = "terraform-google-modules/kubernetes-engine/google"
  project_id                  = var.project_id
  name                        = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  regional                    = false
  region                      = var.region
  zones                       = var.zones
  network                     = data.terraform_remote_state.vpc.outputs.network_name
  subnetwork                  = data.terraform_remote_state.vpc.outputs.subnets_names[0]
  ip_range_pods               = data.terraform_remote_state.vpc.outputs.pod_cidr_name
  ip_range_services           = data.terraform_remote_state.vpc.outputs.service_cidr_name
  create_service_account      = false
  service_account             = var.compute_engine_service_account
  enable_binary_authorization = var.enable_binary_authorization
  skip_provisioners           = var.skip_provisioners
}

/*******************************************
 * Sample Pod
 ******************************************/
resource "kubernetes_pod" "test" {
  metadata {
    name = "terraform-example"
  }

  spec {
    container {
      image = "nginx:1.7.9"
      name  = "example"

      env {
        name  = "environment"
        value = "test"
      }

     port {
        container_port = 8080
      }
    }  
  }
}
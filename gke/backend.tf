terraform {
  backend "gcs" {
    bucket  = "terraform-tf-state-0000"
    prefix  = "gke/state"
    credentials = "./../../terraform-sample-0000-1bdbc5f03007.json"
  }
}
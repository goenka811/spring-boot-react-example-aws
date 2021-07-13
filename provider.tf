provider "google" {
  credentials = file("/Users/rishabhgoenka/Downloads/terraform-gke/spring-boot-react-example-a958326d6750.json")
  project     = "spring-boot-react-example"
  region      = "europe-north1"
  version     = "~> 3.42.0"
}

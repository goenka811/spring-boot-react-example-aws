#provider "google" {
#  version = "~> 3.42.0"
#}
module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on   = [module.gke]
  project_id   = "spring-boot-react-example"
  location     = module.gke.location
  cluster_name = module.gke.name
}
#module "projects_iam_bindings" {
#  source = "terraform-google-modules/iam/google//modules/project_iam"
#  project_id = "spring-boot-react-example"
#}
#resource "local_file" "kubeconfig" {
#  content  = module.gke_auth.kubeconfig_raw
#  filename = "kubeconfig-dev"
#}
module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 2.5"
  project_id   = "spring-boot-react-example"
  network_name = "gke-network-gke-subnet"
  subnets = [
    {
      subnet_name   = "gke-subnet-dev"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = "europe-north1"
    },
  ]
  secondary_ranges = {
    "gke-subnet-dev" = [
      {
        range_name    = "ip-range-pods"
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = "ip-range-services"
        ip_cidr_range = "10.30.0.0/16"
      },
    ]
  }
}

module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id             = "spring-boot-react-example"
  name                   = "spring-boot-react-example-dev"
  regional               = true
  region                 = "europe-north1"
  network                = module.gcp-network.network_name
  subnetwork             = module.gcp-network.subnets_names[0]
  ip_range_pods          = "ip-range-pods"
  ip_range_services      = "ip-range-services"
  create_service_account = true
  node_pools = [
    {
      name                      = "node-pool"
      service_account           = "goenka811@spring-boot-react-example.iam.gserviceaccount.com"
      machine_type              = "e2-medium"
      node_locations            = "europe-north1-b,europe-north1-c,europe-north1-a"
      min_count                 = 1
      max_count                 = 2
      disk_size_gb              = 30
    },
  ]
}

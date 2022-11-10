locals {
  # Simple case
  options = [
    { tags = ["beta", "us-central1-b", "us-central1"], target = {service = "api-beta", peer="dc2"}},
    { tags = ["us-central1-b", "us-central1"],         target = {service = "api", peer="dc2"}},

    { tags = ["beta", "us-central1-a", "us-central1"], target = {service = "api-beta", peer="dc1"}},
    { tags = ["us-central1-a", "us-central1"],         target = {service = "api", peer="dc1"}},

    { tags = ["beta", "us-west1-a", "us-west1"],       target = {service = "api-beta", peer="dc3"}},
    { tags = ["us-west1-a", "us-west1"],               target = {service = "api", peer="dc3"}},

    { tags = ["beta", "us-west1-b", "us-west1"],       target = {service = "api-beta", peer="dc4"}},
    { tags = ["us-west1-b", "us-west1"],               target = {service = "api", peer="dc4"}},
  ]
}

module "sameness1" {
  source = "../sameness/"
  selector = {
    prefer_tags = ["us-central1-a", "us-central1",]
    exclude_tags = ["beta"]
  }
  failovers = local.options
}

resource "local_file" "output_test_file" {
  content = yamlencode(module.sameness1.service_resolver_failover)
  #content = jsonencode(module.sameness1.service_resolver_failover)
  filename = "output.yaml"
}

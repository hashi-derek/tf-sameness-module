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
  filename = "output.yaml"
}

/*
I think we have to require the restriction that all clusters will use the same peer names or have access to the same list of DCs.



EXAMPLE
BetaSVC - dc1 (us-central1-a)
Failovers:
  StableSVC - dc1 (us-central1-a)
  StableSVC - dc2 (us-central1-b)
  Peer1SVC - dc3 (us-central2-a)
  Peer2SVC - dc4 (us-west1-a)


this = {zone = "us-central1-a", region = "us-central1", target = {service = "api-beta"}}

{zone = "us-central1-a", region = "us-central1", target = {service = "api-stable"}},
{zone = "us-central1-b", region = "us-central1", target = {service = "api-stable"}},
{zone = "us-central2-a", region = "us-central2", target = {service = "api-stable", peer="peer1"}},
{zone = "us-west1-a", region = "us-west1", target = {service = "api-stable", peer="peer2"}},
*/
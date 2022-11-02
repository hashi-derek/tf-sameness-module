locals {
  /*
  options = [
    {zone = "z1", region = "r1", target = {service = "s1"}},
    {zone = "z1", region = "r2", target = {service = "s1"}},
    {zone = "z2", region = "r1", target = {service = "s1"}},
    {zone = "z2", region = "r2", target = {service = "s1"}},
    {zone = "z2", region = "r2", target = {service = "s2"}},
    {zone = "z3", region = "r3", target = {service = "s1"}},
  ]
  */

  /* Complex case
  options = [
    {id = "1", zone = "us-central1-a", region = "us-central1", target = {service = "api-beta", datacenter="dc1"}},
    {id = "2", zone = "us-central1-a", region = "us-central1", target = {service = "api", datacenter="dc1"}},
    {id = "3", zone = "us-central1-b", region = "us-central1", target = {service = "api", datacenter="dc2"}},
    {id = "4", zone = "us-central2-a", region = "us-central2", target = {service = "api", peer="peer1"}},
    {id = "5", zone = "us-central2-b", region = "us-central2", target = {service = "api", peer="peer1"}},
    {id = "6", zone = "us-west1-a",    region = "us-west1",    target = {service = "api", peer="peer2"}},
  ]
  */

  # Simple case
  options = [
    {id = "c1b", zone = "us-central1-b", region = "us-central1", target = {service = "api-beta", peer="dc2"}},
    {id = "c1b", zone = "us-central1-b", region = "us-central1", target = {service = "api", peer="dc2"}},

    {id = "c1a", zone = "us-central1-a", region = "us-central1", target = {service = "api-beta", peer="dc1"}},
    {id = "c1a", zone = "us-central1-a", region = "us-central1", target = {service = "api", peer="dc1"}},

    {id = "w1a", zone = "us-west1-a",    region = "us-west1",    target = {service = "api-beta", peer="dc3"}},
    {id = "w1a", zone = "us-west1-a",    region = "us-west1",    target = {service = "api", peer="dc3"}},
  ]
}

module "sameness1" {
  source = "../sameness/"
  selector = {
    zone = "us-central1-a",
    region = "us-central1",
    exclude_ids = ["c1a"]
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
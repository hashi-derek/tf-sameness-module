variable "selector" {
  type = object({
    zone = string
    region = string
    exclude_ids = list(string)
  })
}

variable "failovers" {
  type = list(object({
    id = string
    zone = string
    region = string
    target = object({
      datacenter = optional(string, "")
      partition = optional(string, "")
      peer = optional(string, "")
      service = optional(string, "")
      service_subset = optional(string, "")
      namespace = optional(string, "")
    })
  }))
  default = []
}

output "service_resolver_failover" {
  # Provider needs new failover target support added.
  # Provider rejects validation if more than one of (datacenter, peer, partition) are specified? This is done in consul already.
  # Clean partition by switching "default" to "" in order to support OSS?
  value = local.output
}
output "prepared_query_failover" {
  value = local.output
}

locals {
  no_duplicates = distinct([
    for v in var.failovers: v if (v.id == "" || !contains(var.selector.exclude_ids, v.id))
  ])

  o1 = [
    for v in local.no_duplicates: v if
      var.selector.zone == v.zone &&
      var.selector.region == v.region
  ]
  o2 = [
    for v in local.no_duplicates: v if
      var.selector.zone != v.zone &&
      var.selector.region == v.region
  ]
  priorities = distinct(concat(local.o1, local.o2))
  others = [
    for v in local.no_duplicates: v if !contains(local.priorities, v)
  ]
  output = concat(local.priorities, local.others)
}


      /*
      # Replicate the Consul logic for inheriting default partition / dc / service info.
      # This is used to prevent a service from selecting itself as a failover accidentally.
      if var.this != {
        zone = v.zone
        region = v.region
        target = {
          datacenter = v.target.datacenter == "" ? var.this.target.datacenter : v.target.datacenter
          partition = v.target.partition == "" ? var.this.target.partition : v.target.partition # TODO convert "default" to ""?
          service = v.target.service == "" ? var.this.target.service : v.target.service
          service_subset = v.target.service_subset == "" ? var.this.target.service_subset : v.target.service_subset
          namespace = v.target.namespace == "" ? var.this.target.namespace: v.target.namespace
        }
      }
      */
variable "selector" {
  type = object({
    prefer_tags = list(string)
    exclude_tags = list(string)
  })
}

variable "failovers" {
  type = list(object({
    tags = list(string)
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
  excluded = distinct([
    for f in var.failovers:
      f if length(setintersection(var.selector.exclude_tags, f.tags)) > 0
  ])
  preferred = distinct(flatten([
    for t in var.selector.prefer_tags: [
      for f in var.failovers:
        f
        if contains(f.tags, t)
        && !contains(local.excluded, f)
    ]
  ]))
  others = [
    for f in var.failovers:
      f
      if !contains(local.preferred, f)
      && !contains(local.excluded, f)
  ]
  output = concat(local.preferred, local.others)
}
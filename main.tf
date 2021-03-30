locals {
  zone_id = module.this.enabled ? lookup(data.cloudflare_zones.default[0].zones[0], "id") : null

  rule_groups = module.this.enabled ? flatten([
    for ruleset in var.rulesets : [
      for group in ruleset.rule_groups : {
        package = ruleset.name
        name    = group.name
        mode    = group.mode
        rules   = group.rules
      }
    ]
  ]) : []

  rules = module.this.enabled ? flatten([
    for group in local.rule_groups : [
      for rule in group.rules : {
        package = group.package
        group   = group.name
        id      = rule.id
        mode    = rule.mode
      }
    ]
  ]) : []

  waf_groups = module.this.enabled ? {
    for group in local.rule_groups :
    group.name => group
  } : {}

  waf_package = module.this.enabled ? {
    for ruleset in var.rulesets :
    ruleset.name => ruleset if length(ruleset.mode) > 0
  } : {}

  waf_rules = module.this.enabled ? {
    for rule in local.rules :
    rule.id => rule
  } : {}
}

data "cloudflare_zones" "default" {
  count = module.this.enabled ? 1 : 0

  filter {
    name = var.zone
  }
}

data "cloudflare_waf_packages" "default" {
  for_each = module.this.enabled ? toset(var.rulesets.*.name) : toset(false)

  zone_id = local.zone_id
  filter {
    name = each.key
  }
}

data "cloudflare_waf_groups" "default" {
  for_each = local.waf_groups

  zone_id    = local.zone_id
  package_id = data.cloudflare_waf_packages.default[each.value.package].packages[0].id

  filter {
    name = each.key
  }
}

resource "cloudflare_waf_package" "default" {
  for_each = local.waf_package

  package_id  = data.cloudflare_waf_packages.default[each.key].packages[0].id
  zone_id     = local.zone_id
  sensitivity = each.value.sensitivity
  action_mode = each.value.mode
}

resource "cloudflare_waf_group" "default" {
  for_each = local.waf_groups

  group_id = data.cloudflare_waf_groups.default[each.key].groups[0].id
  zone_id  = local.zone_id
  mode     = each.value.mode
}

resource "cloudflare_waf_rule" "default" {
  for_each = local.waf_rules

  rule_id = each.key
  zone_id = local.zone_id
  mode    = each.value.mode
}

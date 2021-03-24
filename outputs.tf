output "rulesets" {
  value = module.this.enabled ? tolist([
    for ruleset in var.rulesets : {
      id          = data.cloudflare_waf_packages.default[ruleset.name].packages.0.id
      name        = ruleset.name
      sensitivity = ruleset.sensitivity
      mode        = ruleset.mode
      rule_groups : [
        for group in ruleset.rule_groups : {
          id   = data.cloudflare_waf_groups.default[group.name].groups.0.id
          name = group.name
          mode = group.mode
          rules = [
            for rule in group.rules : {
              id   = rule.id
              mode = rule.mode
            }
          ]
        }
      ]
    }
  ]) : []
  description = "A list of `rulesets` objects."
}

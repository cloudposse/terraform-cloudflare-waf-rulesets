variable "zone" {
  type        = string
  description = "The name of the DNS zone."
}

variable "rulesets" {
  type = list(object({
    name        = string
    sensitivity = string
    mode        = string
    rule_groups = list(object({
      name = string
      mode = string
      rules = list(object({
        id   = string
        mode = string
      }))
    }))
  }))
  description = <<-DOC
    A list of `rulesets` objects.
    name:
      The name of the firewall package.
    sensitivity:
      The sensitivity of the firewall package.
    mode:
       The default action that will be taken for rules under the firewall package. 
       Possible values: `simulate`, `block`, `challenge`.
    rule_groups:
      name:
        The name of the firewall rule group.
      mode:
        Whether or not the rules contained within this group are configurable/usable. 
        Possible values: `on`, `off`.
    rules:
      id:
        The ID of the WAF rule.
      mode:
         The mode to use when the rule is triggered. Value is restricted based on the allowed_modes of the rule. 
         Possible values: `default`, `disable`, `simulate`, `block`, `challenge`, `on`, `off`.
  DOC
}

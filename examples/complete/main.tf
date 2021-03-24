module "waf_rulesets" {
  source = "../.."

  zone = var.zone

  rulesets = [
    {
      name        = "OWASP ModSecurity Core Rule Set"
      mode        = "simulate"
      sensitivity = "off"
      rule_groups = [
        {
          name = "OWASP Bad Robots"
          mode = "on"
          rules = [
            {
              id   = "990012" # Rogue web site crawler
              mode = "off"
            },
          ]
        },
      ]
    },
  ]

  context = module.this.context
}

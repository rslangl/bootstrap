plugin "terraform" {
  enabled = true
}

# Global rule: enforce provider version constraint
rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = false
}


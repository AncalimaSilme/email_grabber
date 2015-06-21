# coding: utf-8

module ConformityRulesHelper
  def conformity_rule_type_title type_name
    ConformityRule.Types[type_name]
  end
end

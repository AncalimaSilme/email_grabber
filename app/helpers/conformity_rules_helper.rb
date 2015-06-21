# coding: utf-8

module ConformityRulesHelper
  def conformity_rule_type_title type_name
    { 'equal' => 'Соответствует', 'begins' => 'Начинается', 'contains' => 'Содержит', 'ends' => 'Заканчивается' }[type_name]
  end
end

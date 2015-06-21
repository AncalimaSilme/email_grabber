class ConformityRule < ActiveRecord::Base
  belongs_to :project

  def self.Types
    return {
        'equal' => l('conformity_types.equal'),
        'contains' => l('conformity_types.contains')
    }
  end
end

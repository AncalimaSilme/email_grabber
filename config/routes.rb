resources :emails, :only => [:index, :show]
resources :conformity_rules, :only => [:index, :destroy, :create]
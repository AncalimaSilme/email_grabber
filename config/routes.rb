resources :conformity_rules, :only => [:index, :destroy, :create]
resources :emails, :only => [:index, :show, :destroy] do
  post :archive
end

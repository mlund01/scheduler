Rails.application.routes.draw do
  
  namespace :api, defaults: { format: 'json' } do
  	namespace :v1 do
  		resources :users
  		resources :shifts do
  			collection do
  				get :summary
  			end
  		end
  	end

  end

end

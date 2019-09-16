Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html	

	# Routes related to Users
	get 'users', to: 'users#index' #TODO remove temp route in production
	post 'users/login', to: 'users#login'
	post 'users/new', to: 'users#new'

	# Routes related to Posts
	post 'posts', to: 'posts#index'
	
end

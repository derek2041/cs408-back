Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html	

	# Routes related to Users
	get 'users', to: 'users#index'
	post 'users/login', to: 'users#login'
	post 'users/new', to: 'users#new'
	post 'users/delete', to: 'users#delete'
	post 'users/delete_dev', to: 'users#delete_dev'

	# Routes related to Posts
	post 'posts', to: 'posts#index'
	post 'posts/new', to: 'posts#new'
	post 'posts/view', to: 'posts#view'
	get  'posts/dev', to: 'posts#dev'
	
	# Routes related to Bookmarks
	post 'bookmarks/new', to: 'bookmarks#new'
	post 'bookmarks/view', to: 'bookmarks#view'	
end

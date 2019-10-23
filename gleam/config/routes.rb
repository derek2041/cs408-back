Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html	

	# Routes related to Users
	get 'users', to: 'users#index'
	post 'users/login', to: 'users#login'
	post 'users/new', to: 'users#new'
	post 'users/password', to: 'users#change_password'
	post 'users/delete', to: 'users#delete'
	post 'users/delete_dev', to: 'users#delete_dev' # Development env only

	# Routes related to Posts
	post 'posts', to: 'posts#index'
	post 'posts/new', to: 'posts#new'
	post 'posts/view', to: 'posts#view'
	post 'posts/edit', to: 'posts#edit'
	post 'posts/delete', to: 'posts#delete'
	get  'posts/dev', to: 'posts#dev' # Development env only
	
	# Routes related to Bookmarks
	post 'bookmarks/new', to: 'bookmarks#new'
	post 'bookmarks/delete', to: 'bookmarks#delete'
	post 'bookmarks/view', to: 'bookmarks#view'

	# Routes related to Comments
	post 'comments', to: 'comments#index'
	post 'comments/new', to: 'comments#new'
	post 'comments/edit', to: 'comments#edit'
	post 'comments/delete', to: 'comments#delete'
	post 'comments/view', to: 'comments#view'	
end

class PostsController < ApplicationController
	
	# Index path for post testing
	def index
		# post = Post.all
		# render json: post		

		# Retrieve request body
		data = JSON.parse(request.body.read)
		
		# Check if user request or homepage 
		if data["pageType"] == "home"
			post = Post.order('updated_at DESC')
			return render json: post
		end	








		# Check if attached search query

		
		# pageType - 'home, posts, bookmarks'
		# username
		# password
		# pageNumber
		# searchQuery
	end

	def new

	end
end

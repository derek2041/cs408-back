class PostsController < ApplicationController
	
	# Index path for post testing
	def index
		# POST BODY PARAMETERS		
		# pageType - 'home, posts, bookmarks'
		# username
		# password
		# pageNumber - 1 ... N, sent by front end
		# searchQuery - "" for no query

		# Retrieve request body
		data = JSON.parse(request.body.read)
	
		# Check if homepage 
		if data["pageType"] == "home"	
			# Check if there is an attached search query			
			if data["searchQuery"] == ""
				# No query, return all posts descending by post time (paginated)
				posts = Post.order('updated_at DESC')
					   .paginate(page: data["pageNumber"], per_page: 10)

				# Retrieve post count
				post_count = Post.all.length
				return render json: {count: [count: post_count], data: posts}

			# Search Query attached, filter with SQL
			else
				# Find titles with the search query anywhere in the title
				posts = Post.where("lower(title) LIKE ?", "%" + data["searchQuery"].downcase + "%")
					   .order('updated_at DESC')
					   .paginate(page: data["pageNumber"], per_page: 10)	

				# Retrieve post count
				post_count = Post.all.length
				return render json: {count: [count: post_count], data: posts}
			end
		end	

		# Check if user posts
		if data["pageType"] == "posts"
			# Check for correct user credentials
			if User.is_validated(data)
				# Check for search query
				if data["searchQuery"] == ""
					# If valid and no query, return all the users posts
					posts = User.find_by(username: data["username"])
						    .posts.order('updated_at DESC')
				
					post_count = posts.length
					posts = posts.paginate(page: data["pageNumber"], per_page: 10)

					return render json: {count: [count: post_count], data: posts}

				# Search Query attached
				else
					# Filter user posts by query
					posts = User.find_by(username: data["username"])
						    .posts.where("lower(title) LIKE ?", "%" + data["searchQuery"] + "%")
						    .order('updated_at DESC')
					
					post_count = posts.length
					posts = posts.paginate(page: data["pageNumber"], per_page: 10)

					return render json: {count: [count: post_count], data: posts}

				end
			else
				# If invalid, return an error message
				message = {status: "error", message: "Incorrect Credentials"}
				return render json: message
			end
		end
	end

	def new
		# POST BODY PARAMETERS
		# username
		# password
		# title
		# content
		# post_views - 0 default
		# user_id - foreign key

		# Retrieve request body
		data = JSON.parse(request.body.read)
		
		# Retrieve user entry
		user = User.find_by(username: data["username"])

		# Validate user credentials
		if User.is_validated(data)
			post = Post.new(title: data["title"], content: data["content"], post_views: 0, user_id: user.id)
			post.save!

			message = {status: "success", message: "Post created successfully", id: post.id}
			return render json: message

		else
			# If invalid, return an error message
			message = {status: "error", message: "Incorrect Credentials"}
			return render json: message
		end		
	end

	def view
	end

	def dev
		render json: Post.all
	end
end


# DEFECTS
# - no check that retrieved user exists in new route
# - no messages for empty requests
# - posts pagetype not paginating


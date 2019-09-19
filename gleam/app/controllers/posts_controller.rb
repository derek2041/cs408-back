class PostsController < ApplicationController
	
	# Main post route for homepage, posts, bookmarks, and comments
	def index

		###########################################
		# POST BODY PARAMETERS		
		# pageType - 'home, posts, bookmarks'
		# username
		# password
		# pageNumber - 1 ... N, sent by front end
		# searchQuery - "" for no query
		##########################################

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

				# Search Query in body
				else
					# Filter user posts by query
					posts = User.find_by(username: data["username"])
						    .posts.where("lower(title) LIKE ?", "%" + data["searchQuery"].downcase + "%")
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

		# Check if user bookmarks
		if data["pageType"] == "bookmarks"
			# Check for correct user credentials
			if User.is_validated(data)
				# Retrieve user entry reference and its bookmarks
				user = User.find_by(username: data["username"])
	
				# Check for search query
				if data["searchQuery"] == ""
					# If valid and no query, return all user bookmarks
					sql = "SELECT * FROM bookmarks, posts WHERE bookmarks.post_id = posts.id AND bookmarks.user_id = " + user.id.to_s
					bookmarks = Post.find_by_sql [sql]
					
					# Retrieve number of posts for front-end pagination
					post_count = bookmarks.length
				
					# Retrieve paginated results from database - unique for bookmarks
					bookmarks_paginate = Post.paginate_by_sql(sql, page: data["pageNumber"], per_page: 10)
					return render json: {count: [count: post_count], data: bookmarks_paginate}
				
				# Search Query in body
				else
					# Filter bookmarks by search query
						
					#bookmarks = Post.find_by_sql [sql_with_query]
					bookmarks= Post.find_by_sql ["SELECT * FROM bookmarks, posts 
					WHERE bookmarks.post_id = posts.id AND bookmarks.user_id = ? 
					AND lower(title) LIKE ?", user.id, "%" + data["searchQuery"].downcase + "%"]
										
	
					post_count = bookmarks.length

					bookmarks_search_paginate = Post.paginate_by_sql(["SELECT * FROM bookmarks, posts 
					WHERE bookmarks.post_id = posts.id AND bookmarks.user_id = ? 
					AND lower(title) LIKE ?", user.id, "%" + data["searchQuery"].downcase + "%"], page: data["pageNumber"], per_page: 10)

					#bookmarks = bookmarks.paginate(page: data["pageNumber"], per_page: 10)
					return render json: {count: [count: post_count], data: bookmarks_search_paginate}
				end
			end	
		end
	end

	# Route for creating and adding a new post to the database
	def new

		##########################################
		# POST BODY PARAMETERS
		# username
		# password
		# title
		# content
		# post_views - 0 default
		# user_id - foreign key
		##########################################

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

	# Route for retrieving post detailed information based on ID of post, increments post views
	def view

	end

	# Dev route for viewing all posts in the database, not acessible in production
	def dev
		render json: Post.all
	end
end

# DEFECTS
# - no check that retrieved user exists in new route
# - no messages for empty requests
# - posts pagetype not paginating
# - posts can share the same title (intended?)
# - date["pageNumber"] -> data["pageNumber"]
# - paginate does not work on array for bookmars -> refactor to paginate_by_sql
# - find_by_sql "Too few arguments error"

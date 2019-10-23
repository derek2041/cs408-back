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
				posts = Post.order('created_at DESC')
					   .paginate(page: data["pageNumber"], per_page: 10)

				# Retrieve post count
				post_count = Post.all.length
				return render json: {count: [count: post_count], data: posts}

			# Search Query attached, filter with SQL
			else
				# Find titles with the search query anywhere in the title
				posts = Post.where("lower(title) LIKE ?", "%" + data["searchQuery"].downcase + "%")
					   .order('created_at DESC')
					   .paginate(page: data["pageNumber"], per_page: 10)	

				# Retrieve post count
				post_count = posts.length
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
						    .posts.order('created_at DESC')
				
					post_count = posts.length
					posts = posts.paginate(page: data["pageNumber"], per_page: 10)

					return render json: {count: [count: post_count], data: posts}

				# Search Query in body
				else
					# Filter user posts by query
					posts = User.find_by(username: data["username"])
						    .posts.where("lower(title) LIKE ?", "%" + data["searchQuery"].downcase + "%")
						    .order('created_at DESC')
					
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
					sql = sql + " ORDER BY posts.created_at DESC"
					bookmarks = Post.find_by_sql [sql]
					
					# Retrieve number of posts for front-end pagination
					post_count = bookmarks.length
				
					# Retrieve paginated results from database - unique for bookmarks
					bookmarks_paginate = Post.paginate_by_sql(sql, page: data["pageNumber"], per_page: 10)
					return render json: {count: [count: post_count], data: bookmarks_paginate}
				
				# Search Query in body
				else
					# Filter bookmarks by search query
					bookmarks= Post.find_by_sql ["SELECT * FROM bookmarks, posts 
					WHERE bookmarks.post_id = posts.id AND bookmarks.user_id = ? 
					AND lower(title) LIKE ?", user.id, "%" + data["searchQuery"].downcase + "%"]
									
					# Retrieve list length for front-end pagination		
					post_count = bookmarks.length

					# Retrieve paginated results from database - unique for bookmarks
					bookmarks_search_paginate = Post.paginate_by_sql(["SELECT * FROM bookmarks, posts 
					WHERE bookmarks.post_id = posts.id AND bookmarks.user_id = ? 
					AND lower(title) LIKE ? ORDER BY posts.created_at DESC", user.id, "%" + data["searchQuery"].downcase + "%"], page: data["pageNumber"], per_page: 10)

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
		
		##########################################
		# POST BODY PARAMETERS
		# username
		# password
		# post_id
		##########################################
		
		# Parse data in request
		data = JSON.parse(request.body.read)
	
		# Create user variable and check credentials
		user = nil
		if data["username"] != "null" && data["password"] != "null" && User.is_validated(data) && data["username"] != nil && data["password"] != nil
			user = User.find_by(username: data["username"])	
		end		
	
		# Retrieve post data from Post table
		post = Post.find(data["post_id"])

		# Update post views
		post.post_views = post.post_views + 1
		post.save

		# Check if User created post
		creator = false
		if user != nil && post.user_id == user.id
			creator = true
		end

		# Check if User has post bookmarked
		bookmarked = false
		if user != nil && Bookmark.find_by(user_id: user.id, post_id: post.id)
			bookmarked = true
		end
		
		# Create JSON metadata object
		metadata = {:creator => creator, :bookmarked => bookmarked}

		# Render JSON and metadata
		return render json: {:metadata => metadata, :post => post}		
	end

	# Route to edit a user's post
	def edit

		##########################################
		# POST BODY PARAMETERS
		# username
		# password
		# title
		# content
		# post_id
		##########################################

		# Retrieve request body
		data = JSON.parse(request.body.read)

		# Retrieve User entry and validate creentials
		user = User.find_by(username: data["username"])
		
		if User.is_validated(data)
			
			# Retrieve Post entry
			post = Post.find_by(user_id: user.id, id: data["post_id"])
			post.title = data["title"]
			post.content = data["content"]
			post.save
			
			message = {status: "success", message: "Post updated successfully"}
			return render json: message

		end

		message = {status: "error", message: "Incorrect Credentials"}
		return render json: message

	end

	# Route to delete a user's post
	def delete

		##########################################
		# POST BODY PARAMETERS
		# username
		# password
		# post_id
		##########################################

		# Retrieve post data
		data = JSON.parse(request.body.read)

		# Verify User
		user = User.find_by(username: data["username"])
		
		if User.is_validated(data)
			
			# Retrieve bookmarks that match post to delete
			bookmarks = Bookmark.where(post_id: data["post_id"])
			
			# Delete post entries in bookmark table
			bookmarks.each do |b|
				Bookmark.destroy(b.id)
			end
				
			# Delete Post
			Post.destroy(data["post_id"])

			message = {status: "success", message: "Post deleted successfully"}
			return render json: message
		end

		message = {status: "error", message: "Incorrect Credentials"}
		return render json: message	
	end

	# Dev route for viewing all posts in the database, not acessible in production
	def dev
		render json: Post.all
	end
end

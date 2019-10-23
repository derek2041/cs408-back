class BookmarksController < ApplicationController
	
	# Route to create a new bookmark
	def new

		##########################################
		# POST BODY PARAMETERS
		# username
		# password
		# post_id
		##########################################
		
		# Retrieve request body
		data = JSON.parse(request.body.read)
	
		# Retrieve user making post
		user = User.find_by(username: data["username"])

		# Validate user credentials
		if User.is_validated(data)

			# Retrieve a bookmark entry to check for existing
			check = Bookmark.find_by(user_id: user.id, post_id: data["post_id"])

			# Check if bookmark entry already exists
			if check.present?
				message = {status: "error", message: "Bookmark already exists"}
				return render json: message
			end

			# Create new bookmark entry
			bookmark = Bookmark.new(user_id: user.id, post_id: data["post_id"])
			bookmark.save!
			
			message = {status: "success", message: "Bookmark added", bookmark_id: bookmark.id}
			render json: message	

		else
			message = {status: "error", message: "Incorrect Credentials"}
			render json: message
		end
	end

	# Route to delete a user's bookmarked post
	def delete

		##########################################
		# POST BODY PARAMETERS
		# username
		# password
		# post_id
		##########################################

		# Retrieve Request Body
		data = JSON.parse(request.body.read)
	
		# Retrieve user deleting entry
		user = User.find_by(username: data["username"])

		# Validate user making delete request
		if User.is_validated(data)
						
			# Delete table entry for bookmark
			Bookmark.find_by(user_id: user.id, post_id: data["post_id"]).delete
	
			message = {status: "success", message: "Bookmark deleted"}
			return render json: message	
		end

		message = {status: "error", message: "Incorrect Credentials"}
		return render json: message
	end
	
	# DEV ROUTE - View a user's bookmarked posts for debugging
	def view

		##########################################
		# POST BODY PARAMETERS
		# username
		##########################################

		# Only accessible on development environment
		if Rails.env.development?
			data = JSON.parse(request.body.read)
			user = User.find_by(username: data["username"])
			
			bookmarks = Post.find_by_sql ["SELECT * FROM bookmarks, posts WHERE bookmarks.post_id = posts.id AND bookmarks.user_id = ?", user.id]
			#bookmarks = Bookmark.all
			render json: bookmarks
			#render json: Post.joins("INNER JOIN bookmarks ON bookmarks.post_id = posts.id")
		end
	end
end

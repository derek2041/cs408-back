class BookmarksController < ApplicationController
	def new
		# POST BODY PARAMETERS
		# username
		# password
		# post_id
		
		# Retrieve request body
		data = JSON.parse(request.body.read)
	
		#Retrieve user making post
		user = User.find_by(username: data["username"])

		# Validate user credentials
		if User.is_validated(data)
			bookmark = Bookmark.new(user_id: user.id, post_id: data["post_id"])
			bookmark.save!
			
			message = {status: "success", message: "Bookmark added", bookmark_id: bookmark.id}
			render json: message	

		else
			message = {status: "error", message: "Incorrect Credentials"}
			render json: message
		end
	end
	
	def view
		# TODO remove from public access
		if Rails.env.development?
			data = JSON.parse(request.body.read)
			user = User.find_by(username: data["username"])
			
			bookmarks = Post.find_by_sql ["SELECT * FROM bookmarks, posts WHERE bookmarks.post_id = posts.id AND bookmarks.user_id = ?", user.id]
			render json: bookmarks
			#render json: Post.joins("INNER JOIN bookmarks ON bookmarks.post_id = posts.id")
		end
	end
end

# DEFECTS
# - Doesn't check if user object is null

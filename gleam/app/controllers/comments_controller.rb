class CommentsController < ApplicationController

	# Default route for handling comments, can retrieve post comments and My Comments page
	def index

		###########################################
		# POST BODY PARAMETERS
		# username - if my comments page
		# password - if my comments page		
		# post_id
		# filter -> "Most Recent or Most Viewed"
		# pageNumber
		##########################################

		# Retrieve request body
		data = JSON.parse(request.body.read)

		# Retrieve Post by id
		post = Post.find_by(id: data["post_id"])
		
		# Check if My Comments Page
		comments = nil
		count = 0
		if data["post_id"] == -1
			# Validate User and rerieve their comments
			if User.is_validated(data)
				comments = User.find_by(username: data["username"]).comments
				count = comments.length
			end
			# TODO Add error message for wrong credentials
	
		else
			# Not My Comments Page, retrieve all comments with matching post_id
			comments = post.comments
			count = comments.length
		end

		if data["filter"] == "Most Viewed"
			
			# Order Comments by Views
			comments = comments.order('comment_views DESC').paginate(page: data["pageNumber"], per_page: 10)
			return render json: {count: count, comments: comments}

		elsif data["filter"] == "Most Recent"

			# Order Comments by Creation date
			comments = comments.order('created_at DESC').paginate(page: data["pageNumber"], per_page: 10)	
			return render json: {count: count, comments: comments}
		end	
	end

	# Route to create a new comment on a post
	def new

		###########################################
		# POST BODY PARAMETERS		
		# username
		# password
		# content
		# post_id		
		##########################################

		# Retrieve request body
		data = JSON.parse(request.body.read)

		# Retrieve User and validate credentials
		user = User.find_by(username: data["username"])
		
		if User.is_validated(data)
			
			# Create comment and fill in information
			comment = Comment.new(username: data["username"], content: data["content"], user_id: user.id, post_id: data["post_id"], comment_views: 0)			
			
			# Commit Comment
			comment.save!

			message = {status: "success", message: "Comment created successfully", comment_id: comment.id}
			return render json: message

		end

		message = {status: "error", message: "Incorrect Credentials"}
		return render json: message
	end
	
	# Route to allow user to edit their comments
	def edit

		###########################################
		# POST BODY PARAMETERS		
		# username
		# password
		# content
		# comment_id		
		##########################################

		# Retrieve request body
		data = JSON.parse(request.body.read)
		
		# Retrieve user and validate
		user = User.find_by(username: data["username"])
		
		if User.is_validated(data)

			# Retrieve comment entry and update content
			comment = Comment.find_by(id: data["comment_id"])
			comment.content = data["content"]
			comment.save!
	
			message = {status: "success", message: "Comment updated successfully"}
			return render json: message
		end

		message = {status: "error", message: "Incorrect Credentials"}
		return render json: message
	end

	# Route to allow a user to delete their comments
	def delete

		###########################################
		# POST BODY PARAMETERS		
		# username
		# password
		# comment_id		
		##########################################

		# Retrieve request body
		data = JSON.parse(request.body.read)
		
		# Retrieve user and validate
		user = User.find_by(username: data["username"])
		
		if User.is_validated(data)
		
			# Retrieve and delete comment from Comment table
			Comment.destroy(data["comment_id"])			
		
			message = {status: "success", message: "Comment deleted successfully"}
			return render json: message
		end

		message = {status: "error", message: "Incorrect Credentials"}
		return render json: message
	end

	# Route to increment view count of a comment
	def view

		###########################################
		# POST BODY PARAMETERS		
		# comment_id		
		##########################################

		# Retrieve request body
		data = JSON.parse(request.body.read)	
			
		# Retrieve comment object and update views
		comment = Comment.find_by(id: data["comment_id"])
		comment.comment_views = comment.comment_views + 1
		comment.save

		message = {status: "success", message: "Comment edited successfully"}
		return render json: message
	end
end

require "bcrypt"

class UsersController < ApplicationController

	# Temporary route to view users saved in databsse
	def index
		if Rails.env.development?
			# Retrieve all entries in user table
			tmp = User.all

			# Render as JSON in curl request
			render json: tmp
		end
	end

	# Create a new user
	def new

		###########################################
		# POST BODY PARAMETERS		
		# username
		# password
		##########################################

		# Retrieve request body
		data = JSON.parse(request.body.read)

		# Check if the username already exists in the table
		check = User.find_by username: data["username"]

		# If result is nil, create the user and save to database
		if check.blank?
			hashed_password = BCrypt::Password.create data["password"] # Password passed in POST request

			# Creates the user entry with the passed username nad hashed_password
			user = User.create(username: data["username"], password: hashed_password)
			
			# Commit user to database	
			user.save!

			# Create success message JSON and send	
			message = {status: "success", message: "User created successfully"}
			render json: message	

		# If result is not nil, username is taken, send error back to front end
		else
			# Create error message JSON and send
			message = {status: "error", message: "Username already taken"}	
			render json: message
		end
	end

	# Login a user
	def login

		###########################################
		# POST BODY PARAMETERS		
		# username
		# password
		##########################################

		# Retrieve request body
		data = JSON.parse(request.body.read)

		# Retrieve user entry from database based on passed username parameter
		check = User.find_by username: data["username"]

		# If user was found, verify passed password to hashed entry
		if check.present?
			# Recreate BCrypt password object using string entry in database
			hashed = BCrypt::Password.new check.password
			
			# Compare BCrypt hash to passed password, if true send user info back to front end
			if hashed == data["password"]
				# Create success message JSON and send
				message = {status: "success", username: check.username}
				render json: message
			
			# If password is not a match, return error status
			else
				# Create error message JSON and send 
				message = {status: "error", message: "Incorrect Username or Password"}
				render json: message
			end

		else
			message = {status: "error", message: "Incorrect Username or Password"}
			render json: message
		end
	end

	def change_password
		
		###########################################
		# POST BODY PARAMETERS		
		# username
		# password
		# new_password
		##########################################

		# Retrieve request body
		data = JSON.parse(request.body.read)

		# Validate User credentials
		if User.is_validated(data)
			
			# Retrieve User object to update
			user = User.find_by(username: data["username"])
			
			# Correct Credentials, hash new_password and update database	
			new_hashed_password = BCrypt::Password.create data["new_password"]
			
			user.password = new_hashed_password
			user.save

			# Password updated, send success message
			message = {status: "success", message: "Password changed successfully"}	
			return render json: message

		end
		
		# Incorrect Credentials, return error
		message = {status: "error", message: "Incorrect Credentials"}
		render json: message		
	end


	# Delete a User
	def delete

		###########################################
		# POST BODY PARAMETERS		
		# username
		# password
		##########################################

		data = JSON.parse(request.body.read)
		user = User.find_by(username: data["username"])	
	
		# Validate User Credentials	
		if User.is_validated(data)
				
			# Retrieve all the posts made by the user
			posts = user.posts
			
			# For each post retrieve all bookmark references from the bookmarks table
			posts.each do |p|
				bookmarks = Bookmark.where(post_id: p.id)
				
				# Delete each bookmark reference to the post to be deleted
				bookmarks.each do |b|
					Bookmark.destroy(b.id)
				end
			end

			# Delete the user, posts are destroyed with the dependent association
			User.destroy(user.id)

			message = {status: "success", message: "User deleted successfully"}
			return render json: message
		
		else
			message = {status: "error", message: "Incorrect Username or Password"}
			return render json: message
		end
	end

	# Delete a User (DEV ROUTE)
	def delete_dev

		###########################################
		# POST BODY PARAMETERS		
		# username
		##########################################
		
		if Rails.env.development?
			data = JSON.parse(request.body.read)
			user = User.find_by(username: data["username"])
			# User.destroy(user.id)

			posts = user.posts
			
			posts.each do |p|
				bookmarks = Bookmark.where(post_id: p.id)
				bookmarks.each do |b|
					Bookmark.destroy(b.id)
				end				
			end

			User.destroy(user.id)

			message = {status: "success", message: "User deleted successfully"}
			return render json: message	
		end
	end

end

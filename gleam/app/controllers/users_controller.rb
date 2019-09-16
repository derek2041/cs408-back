require "bcrypt"

class UsersController < ApplicationController

	# Temporary route to view users saved in databsse
	def index
		# Retrieve all entries in user table
		tmp = User.all

		# Render as JSON in curl request
		render json: tmp
	end

	# Create a new user
	def new
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
end

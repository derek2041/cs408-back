require 'bcrypt'

class User < ApplicationRecord	
	has_many :bookmarks, dependent: :destroy
	has_many :comments, dependent: :destroy
	has_many :posts, dependent: :destroy

	def self.is_validated(credentials)


		# Return false if username or password fields are invalid
		if credentials["username"] == nil || credentials["password"] == nil || 
			credentials["username"] == "" || credentials["password"] == "" ||
			credentials["username"] == "null" || credentials["password"] == "null"
			return false
		end

		# If user credentials intact, verify credentials
		user = User.find_by(username: credentials["username"])
		hashed = BCrypt::Password.new user.password

		if hashed == credentials["password"]
			return true
		else 
			return false
		end		
	end
end

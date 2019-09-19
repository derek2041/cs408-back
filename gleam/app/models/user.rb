require 'bcrypt'

class User < ApplicationRecord
	has_many :posts
	has_many :bookmarks
	has_many :comments

	def self.is_validated(credentials)
		user = User.find_by(username: credentials["username"])
		hashed = BCrypt::Password.new user.password

		if hashed == credentials["password"]
			return true
		else 
			return false
		end		
	end
end

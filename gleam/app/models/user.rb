require 'bcrypt'

class User < ApplicationRecord	
	has_many :bookmarks, dependent: :destroy
	has_many :comments, dependent: :destroy
	has_many :posts, dependent: :destroy

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

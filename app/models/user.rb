class User < ActiveRecord::Base
	
	SUCCESS = 1
	ERR_BAD_CREDENTIALS = -1
	ERR_USER_EXISTS = -2
	ERR_BAD_USERNAME = -3
	ERR_BAD_PASSWORD = -4
	MAX_PASSWORD_LENGTH = 128
	MAX_USERNAME_LENGTH = 128

	# Matching User model API, performs logic for User login




	def login(user, password)
		user1 = User.find_by user: user.downcase
		if user1.nil? == true
			return {:errCode => ERR_BAD_CREDENTIALS}
		end
		if user1[:password] == password
			updatedCount = user1[:count] + 1
			user1.update_attributes(:count => updatedCount)

			return {:errCode => SUCCESS, :count => updatedCount}
		else
			return {:errCode => ERR_BAD_CREDENTIALS}
		end

	end

	def TESTAPI_resetFixture()
		Users.delete_all
		return {:errCode => SUCCESS}
	end	

	# Matching User model API, performs logic for adding a new User
  	def add (username, password)
	    result = {}
	    user = nil
	    if username.length > MAX_USERNAME_LENGTH or username.length < 1
	    	result[:errCode] = ERR_BAD_USERNAME
	    	return result
	    end
	    if password.length > MAX_PASSWORD_LENGTH
	    	result[:errorCode] = ERR_BAD_PASSWORD
	    	return result
	    end

	    x = User.find_by user: username
	    if x.nil? == false
	      result[:errCode] = ERR_USER_EXISTS
	      # render json: result
	      return result
	    else
	      user = User.new(:user => username, :password => password)
	      user[:count] = 1
	      result[:errCode] = SUCCESS
	      result[:count] = 1
	    end

	    if user.save
	      # render json: result
	      return result
	    else
	      # TODO
	      return {:errCode => "something messed up"}
	    end
	 end
end
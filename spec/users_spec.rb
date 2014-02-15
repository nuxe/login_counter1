require_relative 'spec_helper.rb'


#    SUCCESS = 1
#    ERR_BAD_CREDENTIALS = -1
#    ERR_USER_EXISTS = -2
#    ERR_BAD_USERNAME = -3
#    ERR_BAD_PASSWORD = -4
#    MAX_PASSWORD_LENGTH = 128
#    MAX_USERNAME_LENGTH = 128

describe "Users" do
  describe "GET /users/add", :type => :request do
    it "Add New User works" do
    	u = ::User.new
    	x = u.add("user1", "pass1")
    	expect(x[:errCode]).to eq(1)
        expect(x[:count]).to eq(1)
    end

    it "Logging in with bad credentials" do
    	u = ::User.new
    	x = u.login('does not exist', 'pass1')
    	expect(x[:errCode]).to eq(-1)
    end


    it "empty username should generate -3" do
        u = ::User.new
        x = u.add('', 'pass1')
        expect(x[:errCode]).to eq(-3)
    end

    it "add new user and then login" do
    	u = ::User.new
    	x = u.add('kush', 'pass1')
        x = u.login('kush', 'pass1')
    	expect(x[:errCode]).to eq(1)
    	expect(x[:count]).to eq(2)
    end

    it "Add user then  login twice" do
        u = ::User.new
        x = u.add('user1', 'pass1')
        x = u.login('user1', 'pass1')
        x = u.login('user1', 'pass1')
        expect(x[:count]).to eq(3)
        expect(x[:errCode]).to eq(1)
    end

    it "Add user then  login thrice" do
        u = ::User.new
        x = u.add('user1', 'pass1')
        x = u.login('user1', 'pass1')
        x = u.login('user1', 'pass1')
        x = u.login('user1', 'pass1')
        expect(x[:count]).to eq(4)
        expect(x[:errCode]).to eq(1)
    end

    it "Add user then  login four times" do
        u = ::User.new
        x = u.add('user1', 'pass1')
        x = u.login('user1', 'pass1')
        x = u.login('user1', 'pass1')
        x = u.login('user1', 'pass1')
        x = u.login('user1', 'pass1')

        expect(x[:count]).to eq(5)
        expect(x[:errCode]).to eq(1)
    end




    it "Username too long" do
    	u = ::User.new
    	x = u.add('user123user123user123user123user123user123user123user123user123user123user123user123user123user123user123user123user123user123user123', 'pass1')
    	expect(x[:errCode]).to eq(-3)
    end

    it "bad credentials" do
    	u = ::User.new
    	x = u.add('user1', 'pass1')
    	x = u.login('user1', 'pass122')
    	expect(x[:errCode]).to eq(-1)
    end

    it "Same usernames" do
    	u = ::User.new
    	x = u.add('user1', 'pass1')
    	x = u.add('user1', 'pass1')
    	expect(x[:errCode]).to eq(-2)
    end
  end
end
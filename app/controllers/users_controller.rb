class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_filter :set_up_error_codes
  skip_before_filter  :verify_authenticity_token

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # Use this to set up all ERROR_X values to be used as class variables
  # As well as global constants
  def set_up_error_codes
    @SUCCESS = 1
    @ERR_BAD_CREDENTIALS = -1
    @ERR_USER_EXISTS = -2
    @ERR_BAD_USERNAME = -3
    @ERR_BAD_PASSWORD = -4
    @MAX_PASSWORD_LENGTH = 128
    @MAX_USERNAME_LENGTH = 128
  end

  ################ TEST API METHODS ############################
  ##############################################################
  # Method for /user/login endpoint, filters out bad input
  def login_method
    user = User.new
    x = user.login(user_params[:user], user_params[:password])
    render json: x
  end

  def add_helper
    user_name = user_params[:user]
    password = user_params[:password]

    if (user_name.length > 128 or user_name.length == 0)
      render json: {:errCode => @ERR_BAD_USERNAME}
      return -3
    elsif (password.length > 128)
      render json: {:errCode => @ERR_BAD_PASSWORD}
      return -4
    else
      user = User.new
      x = user.add(user_name, password)
      render json: x
    end
  end


  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    logger.debug user_params
    respond_to do |format|
      if @user.save
#        format.html { redirect_to @user, notice: 'User was successfully created. NOT' }
        format.json { render action: 'show', status: :created, location: @user }
      else
 #       format.html { render action: 'new NAA' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end


  ################ TEST API METHODS ############################
  ##############################################################
  def reset
    connection = ActiveRecord::Base.connection
    ActiveRecord::Base.connection.execute("DELETE FROM users") 
    render json: {:errCode => 1}
  end

  def unitTest
    # puts "UNIT TESTING"
    # stdin, stdout = Open3.popen3("rake test")
    # puts "RAN"
    # x = stdout.gets(nil)
    # puts "STDOUT"
    # puts stdout.nil?
    # x = `rake test RAILS_ENV=test`
    x = `rake spec`
    number_of_failures = x[/\d+ failures/].split(" ")[0].to_i
    number_of_tests = x[/\d+ examples,/].split(" ")[0].to_i

    render json: {:output => x, :nrFailed => number_of_failures, :totalTests => number_of_tests}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.permit(:user, :password)
    end

end
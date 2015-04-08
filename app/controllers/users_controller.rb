class UsersController < ApplicationController
  before_action :require_non_production, only: [:new, :create]
  before_action :require_login, only: [:show, :edit, :update]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :set_campuses, only: [:new, :show, :edit, :update]
  before_action :user_is_current, only: [:edit, :update]

  def index
    @users = User.all
    respond_to do |format|
      format.json do
        render json: 'Not logged in' if current_user.nil?

        users = @users.collect do |user|
          { id: user.id, name: user.name, avatar: user.profile_picture_url }
        end

        render json: users
      end

      format.html { require_non_production }
    end
  end

  def new
    request.env['omniauth.auth'] = {}
    request.env['omniauth.auth']['info'] = {}

    request.env['omniauth.auth']['uid'] = 'asd'
    request.env['omniauth.auth']['info']['name'] = ''
    request.env['omniauth.auth']['info']['mail'] = ''

    shibboleth_callback
  end

  def update
    if @user.update(edit_user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to feed_index_path
    else
      redirect_to action: 'new'
    end
  end

  def set_first_time_use
    value = params[:value]
    current_user.update_attribute(:first_time, value)

    if value
      redirect_to feed_index_path
    else
      redirect_to notifications_path
    end
  end

  def set_profile_picture
    id = params[:pic_id].to_i
    photo = Photo.find(id)

    if photo.nil?
      redirect_to :back, alert: 'Invalid photo!'
    else
      current_user.update_attribute(:profilePicture, id)
      redirect_to current_user, notice: 'Profile picture changed.'
    end
  end

  def shibboleth_callback
    uid = request.env['omniauth.auth']['uid']
    @user = User.find_by username: uid

    if @user.nil?
      name = request.env['omniauth.auth']['info']['name'].force_encoding('utf-8')
      mail = request.env['omniauth.auth']['info']['mail']

      @user = User.new username: uid, name: name, email: mail
      render action: 'new'
    else
      session[:user_id] = @user.id
      redirect_to feed_index_path
    end
  end

  private

  def user_is_current
    redirect_to root_path unless params[:id].to_s === session[:user_id].to_s
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :name, :title, :email, :campus, :unit, :about, :profilePicture)
  end

  def edit_user_params
    params.require(:user).permit(:title, :campus, :unit, :about, :profilePicture)
  end

  def set_campuses
    @campuses = ['City Centre Campus',
                 'Kumpula Campus',
                 'Meilahti Campus',
                 'Viikki Campus']
  end
end

class HashtagsController < ApplicationController
  before_action :require_login

  before_action :set_hashtag, only: [:show, :update, :join, :leave, :invite]
  before_action :user_has_tag, only: [:show, :update]
  before_action :topic_updater, only: [:show, :update]

  def index
    respond_to do |format|
      format.json do
        render json: 'Not logged in' && return if current_user.nil?

        tags = Hashtag.all.collect do |tag|
          { id: tag.id, tag: tag.tag }
        end

        render json: tags
      end

      format.html { redirect_to root_path }
    end
  end

  def show
    @messages = @hashtag.messages.last(20)

    @topic_button_text = 'Edit channel'
  end

  def join
    current_user.hashtags << @hashtag
    request.env['chat.join_callback'].call(current_user, @hashtag)
    redirect_to hashtag_path(tag: @hashtag.tag)
  end

  def leave
    current_user.hashtags.destroy(@hashtag)
    request.env['chat.leave_callback'].call(current_user, @hashtag)
    redirect_to hashtag_path(@hashtag.tag)
  end

  def add_multiple
    new_tags = Array.new
    tags = params[:hashtags]
    unless tags.nil?
      tags.split(',').each do |tag_name|
        h = Hashtag.find_by tag: tag_name
        h = Hashtag.create tag: tag_name if h.nil?
        new_tags << h
      end
    end

    current_user.hashtags = (current_user.hashtags | new_tags) & new_tags

    if request.referer and URI(request.referer).path == user_path(current_user.id)
      redirect_to :back, notice: 'Your favourite things updated!'
    else 
      redirect_to feed_index_path
    end   
  end

  def update
    @hashtag.topic_updater_id = current_user.id

    redirect_to(hashtag_path(@hashtag.tag), notice: 'Something went wrong!') &&
      return unless @hashtag.update(hashtag_params)

    @hashtag.users.each do |user|
      next if user == current_user

      Notification.create notification_type: 2,
                          user: user,
                          tricker_user: current_user,
                          tricker_hashtag: @hashtag

      request.env['chat.notification_callback'].call(user.id)
    end

    redirect_to hashtag_path(@hashtag.tag), notice: 'Topic was successfully updated.'
  end

  def create
    hashtag = Hashtag.find_by tag: params[:tag]
    if hashtag == nil
      hashtag = Hashtag.new tag: params[:tag]
      unless hashtag.save
        redirect_to feed_index_path, alert: 'Something went wrong!'
        return 
      end
    end
    
    current_user.hashtags << hashtag
    redirect_to hashtag_path(hashtag.tag)
  end

  def invite
    user = User.find_by(name: params[:user])

    if user.hashtags.include? @hashtag
      respond_to do |format|
        format.html { redirect_to hashtag_path(@hashtag), alert: 'User already a member!' }
        format.json { render status: 400 }
      end

      return
    end

    Notification.create notification_type: 1,
                        user_id: user.id,
                        tricker_user: current_user,
                        tricker_hashtag: @hashtag

    request.env['chat.notification_callback'].call(user.id)

    respond_to do |format|
      format.html { redirect_to hashtag_path(@hashtag.tag) }
      format.json { render json: { name: user.name, avatar: user.profile_picture_url } }
    end
  end

  private

  def set_hashtag
    @hashtag = Hashtag.find_by(tag: params[:tag])
    render 'errors/error' if @hashtag.nil?
  end

  def user_has_tag
    @user_has_tag = current_user.hashtags.include? @hashtag
  end

  def hashtag_params
    params.require(:hashtag).permit(:topic, :topic_updater_id, :cover_photo)
  end

  def topic_updater
    @topicker = User.find(@hashtag.topic_updater_id)
    rescue
      @topicker = nil
  end
end

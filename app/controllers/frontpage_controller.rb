class FrontpageController < ApplicationController
  def index
    @login_url = ENV['RAILS_ENV'] == 'production' ? '/auth/shibboleth' : users_path

    # redirect_to feed_index_path unless current_user.nil?
    redirect_to feed_index_path unless session[:user_id].nil?
  end
end

class UserHashtagsController < ApplicationController
  before_action :require_login

  def update
    user_hashtag = UserHashtag.find(params[:id])

    if user_hashtag.favourite?
      user_hashtag.update(favourite: false)
    else
      if UserHashtag.where(user_id: current_user.id, favourite: true).count < APP_CONFIG['max_faves']
        user_hashtag.update(favourite: true)
      else
        redirect_to feed_index_path(tab: 'favourites'),
                    alert: "You already have #{APP_CONFIG['max_faves']} favourites, remove some to add a new one!"
        return
      end
    end

    redirect_to request.referer + params[:backurl]
  end
end

class User < ActiveRecord::Base
  validates :name, presence: true

  has_many :user_hashtags, dependent: :destroy
  has_many :hashtags, through: :user_hashtags
  has_many :messages, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :photos, dependent: :destroy

  def unread_notifications?
    notifications.unread_count > 0
  end

  def profile_picture_url
    photo = Photo.find_by id: profilePicture
    return ActionController::Base.helpers.asset_path('missing.png') if photo.nil?

    photo.image.url(:thumb)
  end
end

class Book < ApplicationRecord
  belongs_to :user

  has_many :favorites, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { maximum: 200 }

  scope :with_details, -> { includes(:favorites, user: { profile_image_attachment: :blob }) }

  def favorited_by?(user)
    favorites.any? { |favorite| favorite.user_id == user.id }
  end
end

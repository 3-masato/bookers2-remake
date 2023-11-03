class Room < ApplicationRecord
  belongs_to :user

  has_many :chats, dependent: :destroy
  has_many :entries, dependent: :destroy

  def users_except_current_user(current_user)
    entries.includes(:user).where.not(user_id: current_user.id).map(&:user)
  end
end

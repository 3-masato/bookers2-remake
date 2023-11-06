class User < ApplicationRecord
  include Searchable

  GUEST_USER_EMAIL = "guest@example.com"

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :profile_image

  has_many :books, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_many :view_counts, dependent: :destroy

  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  has_many :followings, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  has_many :chats, dependent: :destroy
  has_many :entries, dependent: :destroy

  validates :name, uniqueness: true, length: { in: 2..20 }
  validates :introduction, length: { maximum: 50 }

  scope :with_details, -> { includes(:followings, :followers, profile_image_attachment: :blob) }

  def get_profile_image
    (profile_image.attached?) ? profile_image : "default-user-icon.jpeg"
  end

  def follow(user)
    unless following?(user)
      active_relationships.create(followed_id: user.id)
    end
  end

  def unfollow(user)
    if following?(user)
      active_relationships.find_by(followed_id: user.id).destroy
    end
  end

  def following?(user)
    followings.include?(user)
    # followings.any? { |following| following.id == user.id }
  end

  def chat_data(other_user)
    self_user_entry = Entry.where(user_id: self.id)
    other_user_entry = Entry.where(user_id: other_user.id)

    current_room_id = find_common_room_id(self_user_entry, other_user_entry)

    if current_room_id
      { room_id: current_room_id }
    else
      {
        room: Room.new,
        entry: Entry.new
      }
    end
  end

  def guest_user?
    email == GUEST_USER_EMAIL
  end

  def self.guest
    find_or_create_by!(email: GUEST_USER_EMAIL) do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = "Guest User"
    end
  end

  private
  # Finds the common room ID shared between two users based on their entries.
  # If no common room exists, returns nil.
  #
  # @param user_a_entries [Entry] Entries related to the first user.
  # @param user_b_entries [Entry] Entries related to the second user.
  #
  # @return [Integer, nil] Returns the ID of the common room if found, otherwise nil.
  def find_common_room_id(user_a_entries, user_b_entries)
    user_a_entries.pluck(:room_id).each do |a_room_id|
      return a_room_id if user_b_entries.exists?(room_id: a_room_id)
    end

    nil
  end
end

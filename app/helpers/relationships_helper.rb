module RelationshipsHelper
  # Checks if two users are following each other.
  #
  # @param user_a [User] The first user.
  # @param user_b [User] The second user.
  #
  # @return [Boolean] Returns true if the two users are following each other, otherwise false.
  def mutual_following?(user_a, user_b)
    user_a.following?(user_b) && user_b.following?(user_a)
  end

  # Determines if the chat link should be displayed for the given users.
  # The chat link is shown only if the two users are not the same and they are following each other.
  #
  # @param current_user [User] The currently logged-in user.
  # @param user [User] The other user being checked.
  #
  # @return [Boolean] Returns true if the chat link should be shown, otherwise false.
  def show_chat_link?(current_user, user)
    current_user != user && mutual_following?(current_user, user)
  end
end

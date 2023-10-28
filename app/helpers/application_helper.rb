module ApplicationHelper
  ##
  # Returns a set of navigation items based on the user's sign-in status.
  #
  # @param signed_in [Boolean] A flag indicating whether the user is signed in.
  # @return [Array<Hash>] An array of navigation items.
  #   @option (Hash) :path [String] The URL destination for the link.
  #   @option (Hash) :fa_class [String] The FontAwesome icon class.
  #   @option (Hash) :text [String] The display text for the link.
  #   @option (Hash) :method (optional) [Symbol] The HTTP method (e.g., :delete).
  #
  def get_nav_items(signed_in)
    signed_in ? [
      {
        path: user_path(current_user),
        fa_class: "fa-solid fa-house",
        text: "Home"
      },
      {
        path: users_path,
        fa_class: "fa-solid fa-users",
        text: "Users"
      },
      {
        path: books_path,
        fa_class: "fa-solid fa-book-open",
        text: "Books"
      },
      {
        path: destroy_user_session_path,
        fa_class: "fa-solid fa-right-from-bracket",
        text: "Log out",
        method: :delete,
      }
    ] : [
      {
        path: root_path,
        fa_class: "fa-solid fa-house",
        text: "Home"
      },
      {
        path: home_about_path,
        fa_class: "fa-solid fa-link",
        text: "About"
      },
      {
        path: new_user_registration_path,
        fa_class: "fa-solid fa-user-plus",
        text: "Sign up"
      },
      {
        path: new_user_session_path,
        fa_class: "fa-solid fa-right-to-bracket",
        text: "Log in"
      }
    ]
  end
end

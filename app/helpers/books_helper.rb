module BooksHelper
  def empty_index_text(user, page)
    is_current_user = user == current_user

    case page
    when :books
      if is_current_user
        "There are no books posted. Share your thoughts on the books you have read!"
      else
        "This user has not posted anything yet."
      end
    when :favorited
      "This user has not favorited anything yet."
    end
  end
end

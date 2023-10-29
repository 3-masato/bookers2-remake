module BooksHelper
  def empty_index_text(user)
    if user == current_user
      "There are no books posted. Share your thoughts on the books you have read!"
    else
      "This user has not submitted anything yet."
    end
  end
end

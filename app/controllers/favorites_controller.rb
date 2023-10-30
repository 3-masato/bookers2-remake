class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def create
    @book = Book.find(params[:book_id])
    current_user.favorites.create(book_id: @book.id)
  end

  def destroy
    @book = Book.find(params[:book_id])
    fav = current_user.favorites.find_by(book_id: @book.id)
    fav && fav.destroy # Countermeasures against unauthorized destroy actions
  end
end

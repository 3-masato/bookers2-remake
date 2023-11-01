class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, only: [:create, :destroy]

  def create
    current_user.favorites.create(book_id: @book.id)
  end

  def destroy
    fav = current_user.favorites.find_by(book_id: @book.id)
    fav&.destroy # Countermeasures against unauthorized destroy actions
  end

  private
  def set_book
    @book = Book.find(params[:book_id])
  end
end

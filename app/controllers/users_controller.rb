class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update]
  before_action :ensure_guest_user, only: [:edit]
  before_action :set_user, only: [:show, :edit, :posted, :favorited, :update]

  rescue_from ActiveRecord::RecordNotFound do |e|
    redirect_to users_path
  end

  def index
    @users = User.with_details
    @user = current_user
  end

  def show
    @books = @user.books.with_details
  end

  def edit
  end

  def favorited
    @books = @user.favorited_books.with_details
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "You have updated user successfully."
    else
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_correct_user
    user = User.find(params[:id])
    unless user == current_user
      redirect_to user_path(current_user)
    end
  end

  def ensure_guest_user
    user = User.find(params[:id])
    if user.guest_user?
      redirect_to user_path(current_user), alert: "Guest users cannot go to the edit profile page."
    end
  end
end

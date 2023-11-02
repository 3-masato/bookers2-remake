class RelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:create, :destroy, :followings, :followers]

  def create
    current_user.follow(@user)
  end

  def destroy
    current_user.unfollow(@user)
  end

  def followings
    @users = @user.followings
  end

  def followers
    @users = @user.followers
  end

  def set_user
    @user = User.find(params[:user_id])
  end
end

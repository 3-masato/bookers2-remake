class ChatsController < ApplicationController
  before_action :authenticate_user!, only: [:create]
  before_action :ensure_user_entry_exists, only: [:create]

  def create
    @chat = current_user.chats.new(chat_params)
    @chats = Room.find(params[:chat][:room_id]).chats

    handle_redirect unless @chat.save
  end

  private
  def chat_params
    params.require(:chat).permit(:message, :room_id)
  end

  def ensure_user_entry_exists
    return if Entry.exists?(user_id: current_user.id, room_id: params[:chat][:room_id])

    handle_redirect
  end

  def handle_redirect
    redirect_back(fallback_location: root_path)
  end
end

class HomesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do |e|
    redirect_to top_path
  end

  def top
  end

  def about
  end
end

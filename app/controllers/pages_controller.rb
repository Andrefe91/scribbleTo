class PagesController < ApplicationController
  def index
    if params[:name].present?
      redirect_to scribble_path(name: params[:name]) and return
    end
  end
end

class ScribbleController < ApplicationController
  def show
    @scribble = Scribble.find_by(name: params[:name])
  end

  def new
  end

  def create
  end
end

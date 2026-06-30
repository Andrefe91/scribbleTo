class ScribblesController < ApplicationController
  def show
    @scribble = Scribble.find_by(name: params[:name])
    redirect_to new_scribble_path(name: params[:name]), alert: "Item not found" and return if @scribble.nil?
  end

  def new

    if params[:name].present? && Scribble.exists?(name: params[:name])
      redirect_to scribble_path(params[:name]), alert: "That scribble already exists!" and return
    end

    @scribble = Scribble.new(name: params[:name])

    #This triggers the name normalization when the Scribble name is written on the URL
    @scribble.valid?
  end

  def create
    # Pass the strong params method instead of the raw params hash
    @scribble = Scribble.new(scribble_params)

    if @scribble.save
      redirect_to scribble_path(@scribble), notice: "Scribble was successfully created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def check_uniqueness
    exists = Scribble.exists?(["LOWER(name) = ?", params[:name].to_s.downcase])

    render json: { unique: !exists }
  end

  private

  def scribble_params
    params.require(:scribble).permit(:name, :body, :locked, :password, :deleteTime)
  end
end

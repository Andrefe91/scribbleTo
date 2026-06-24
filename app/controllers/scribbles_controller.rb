class ScribblesController < ApplicationController
  def show
    @scribble = Scribble.find_by(name: params[:name])
    redirect_to new_scribble_path(name: params[:name]), alert: "Item not found" and return if @scribble.nil?
  end

  def new
    @scribble = Scribble.new
    puts "New Scribble #{params[:name]}"
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

  private

  def scribble_params
    params.require(:scribble).permit(:name, :body, :password)
  end
end

class ScribblesController < ApplicationController
  before_action :set_scribble, only: [ :show, :check_password, :verify_password ]

  def show
    unlocked_list = session[:unlocked_scribbles] || []

    if @scribble.password_digest.present? && unlocked_list.exclude?(@scribble.name)
      redirect_to check_password_scribble_path(@scribble.name) and return
    end
  end

  def new
    if params[:name].present? && Scribble.exists?(name: params[:name])
      redirect_to scribble_path(params[:name]), alert: "That scribble already exists!" and return
    end

    @scribble = Scribble.new(name: params[:name])
  end

  def create
    # Pass the strong params method instead of the raw params hash
    @scribble = Scribble.new(scribble_params)

    if @scribble.save
      session[:unlocked_scribbles] << @scribble.name
      redirect_to scribble_path(@scribble), notice: "Scribble was successfully created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def check_uniqueness
    exists = Scribble.exists?([ "LOWER(name) = ?", params[:name].to_s.downcase ])
    render json: { unique: !exists }
  end

  def check_password
  end

  def verify_password
    if @scribble.authenticate(params[:password])
      session[:unlocked_scribbles] ||= []
      session[:unlocked_scribbles] << @scribble.name

      redirect_to scribble_path(@scribble.name), notice: "Access Granted!"
    else
      redirect_to check_password_scribble_path(@scribble.name), alert: "Incorrect Password..."
    end
  end

  private

  def scribble_params
    params.require(:scribble).permit(:name, :body, :locked, :password, :deleteTime)
  end

  def set_scribble
    normalized_name = Scribble.normalizeName(params[:name])
    @scribble = Scribble.find_by!(name: normalized_name)
  rescue ActiveRecord::RecordNotFound
    redirect_to new_scribble_path(name: Scribble.normalizeName(params[:name])), alert: "Item not found" and return
  end
end

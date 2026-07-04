class ScribblesController < ApplicationController
  before_action :initialize_session
  before_action :set_scribble, only: [ :show, :update, :check_password, :verify_password ]
  before_action :set_paper_trail_whodunnit

  # Security of the Scribble Show and Update Actions
  before_action :ensure_scribble_is_unlocked, only: [ :show, :update ]

  def show
    # Fetch the version history specifically for this scribble's rich text body
    @body_versions = @scribble.body&.versions || []

    # If the user clicks a historical version link, load that specific snapshot
    if params[:version_id].present?
      version = @scribble.body.versions.find_by(id: params[:version_id])
      @historical_rich_text = version.reify
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
      redirect_to scribble_path(@scribble), notice: "Scribble was successfully created!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @scribble.update(scribble_params)
      redirect_to scribble_path(@scribble), notice: "Scribble was successfully updated!"
    else
      @scribble.restore_attributes([ :name ])
      render :show, status: :unprocessable_entity
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
      session[:unlocked_scribbles] << @scribble.name

      redirect_to scribble_path(@scribble.name), notice: "Access Granted!"
    else
      redirect_to check_password_scribble_path(@scribble.name), alert: "Incorrect Password..."
    end
  end

  def clear_scribble_session
    session[:unlocked_scribbles]&.delete(params[:name])
    session[:unlocked_scribbles] = session[:unlocked_scribbles]

    redirect_to root_path, notice: "Scribble Locked!"
  end

  private

  def ensure_scribble_is_unlocked
    unlocked_list = session[:unlocked_scribbles] || []

    if @scribble.password_digest.present? && unlocked_list.exclude?(@scribble.name)
      redirect_to check_password_scribble_path(@scribble.name), alert: "This scribble is locked." and return
    end
  end

  def initialize_session
    session[:unlocked_scribbles] ||= []
  end

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

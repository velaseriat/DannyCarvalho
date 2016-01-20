class PhotosController < ApplicationController
  before_action :set_photo, only: [:show, :edit, :update, :destroy]

  # GET /photos
  # GET /photos.json
  def index
    @photos = Photo.all.order(:dateTime).where(:presskit => false).reverse

    @photo_sets = Array.new

    i = 0
    photo_set = Array.new
    @photos.each do |photo|
      if i < 4
        photo_set << photo
        i = i + 1
      end
      if i >= 4
        @photo_sets << photo_set
        photo_set = Array.new
        i = 0
      end
    end
    @photo_sets << photo_set
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
  end

  # GET /photos/new
  def new
    if !user_signed_in?
      redirect_to :root
    else
      @photo = Photo.new
    end
  end

  # GET /photos/1/edit
  def edit
    if !user_signed_in?
      redirect_to :root
    end
  end

  # POST /photos
  # POST /photos.json
  def create
    if !user_signed_in?
      redirect_to :root
    else
      @photo = Photo.new(photo_params)

      respond_to do |format|
        if @photo.save
          format.html { redirect_to @photo, notice: 'Photo was successfully created.' }
          format.json { render :show, status: :created, location: @photo }
        else
          format.html { render :new }
          format.json { render json: @photo.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /photos/1
  # PATCH/PUT /photos/1.json
  def update
    if !user_signed_in?
      redirect_to :root
    else
      respond_to do |format|
        if @photo.update(photo_params)
          format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
          format.json { render :show, status: :ok, location: @photo }
        else
          format.html { render :edit }
          format.json { render json: @photo.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    if !user_signed_in?
      redirect_to :root
    else
      @photo.destroy
      respond_to do |format|
        format.html { redirect_to photos_url, notice: 'Photo was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      params.require(:photo).permit(:image_filepath, :dateTime, :text, :title, :presskit)
    end
  end

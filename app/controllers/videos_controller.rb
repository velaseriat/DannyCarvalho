class VideosController < ApplicationController
  before_action :set_video, only: [:show, :edit, :update, :destroy]

  # GET /videos
  # GET /videos.json
  def index
    @videos = Video.all
    @video_sets = Array.new

    i = 0
    video_set = Array.new
    @videos.each do |video|
      if i < 4
        video_set << video
        i = i + 1
      end
      if i >= 4
        @video_sets << video_set
        video_set = Array.new
        i = 0
      end
    end
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
  end

  # GET /videos/new
  def new
    if !user_signed_in?
      redirect_to :root
    else
      @video = Video.new
    end
  end

  # GET /videos/1/edit
  def edit
    if !user_signed_in?
      redirect_to :root
    end
  end

  # POST /videos
  # POST /videos.json
  def create
    if !user_signed_in?
      redirect_to :root
    else
      @video = Video.new(video_params)

      respond_to do |format|
        if @video.save
          format.html { redirect_to @video, notice: 'Video was successfully created.' }
          format.json { render :show, status: :created, location: @video }
        else
          format.html { render :new }
          format.json { render json: @video.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /videos/1
  # PATCH/PUT /videos/1.json
  def update
    if !user_signed_in?
      redirect_to :root
    else
      respond_to do |format|
        if @video.update(video_params)
          format.html { redirect_to @video, notice: 'Video was successfully updated.' }
          format.json { render :show, status: :ok, location: @video }
        else
          format.html { render :edit }
          format.json { render json: @video.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    if !user_signed_in?
      redirect_to :root
    else
      @video.destroy
      respond_to do |format|
        format.html { redirect_to videos_url, notice: 'Video was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      @video = Video.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def video_params
      params.require(:video).permit(:title, :description, :url_path, :thumbnail_url)
    end
  end

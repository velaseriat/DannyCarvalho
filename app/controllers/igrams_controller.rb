class IgramsController < ApplicationController
  before_action :set_igram, only: [:show, :edit, :update, :destroy]

  # GET /igrams
  # GET /igrams.json
  def index
    @igrams = Igram.all.order(:dateTime).reverse

    @igram_sets = Array.new

    i = 0
    igram_set = Array.new
    @igrams.each do |ig|
      if i < 4
        igram_set << ig
        i = i + 1
      end
      if i >= 4
        @igram_sets << igram_set
        igram_set = Array.new
        i = 0
      end
    end
    @igram_sets << igram_set
  end

  # GET /igrams/1
  # GET /igrams/1.json
  def show
  end

  # GET /igrams/new
  def new
    if !user_signed_in?
      redirect_to :root
    else
      @igram = Igram.new
    end
  end

  # GET /igrams/1/edit
  def edit
    if !user_signed_in?
      redirect_to :root
    end
  end

  # POST /igrams
  # POST /igrams.json
  def create
    if !user_signed_in?
      redirect_to :root
    else
      @igram = Igram.new(igram_params)

      respond_to do |format|
        if @igram.save
          format.html { redirect_to @igram, notice: 'Igram was successfully created.' }
          format.json { render :show, status: :created, location: @igram }
        else
          format.html { render :new }
          format.json { render json: @igram.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /igrams/1
  # PATCH/PUT /igrams/1.json
  def update
    if !user_signed_in?
      redirect_to :root
    else
      respond_to do |format|
        if @igram.update(igram_params)
          format.html { redirect_to @igram, notice: 'Igram was successfully updated.' }
          format.json { render :show, status: :ok, location: @igram }
        else
          format.html { render :edit }
          format.json { render json: @igram.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /igrams/1
  # DELETE /igrams/1.json
  def destroy
    if !user_signed_in?
      redirect_to :root
    else
      @igram.destroy
      respond_to do |format|
        format.html { redirect_to igrams_url, notice: 'Igram was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_igram
      @igram = Igram.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def igram_params
      params.require(:igram).permit(:image_path, :link, :text, :dateTime, :url)
    end
  end

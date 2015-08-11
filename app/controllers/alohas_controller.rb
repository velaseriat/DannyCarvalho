class AlohasController < ApplicationController
  before_action :set_aloha, only: [:show, :edit, :update, :destroy]


  def about
    @content = Aloha.first.content
    respond_to do |format|
      format.html { render :about }
    end
  end
  # GET /alohas
  # GET /alohas.json
  def index
    threeEvents = Event.where('dateTime > ?', DateTime.now).order(:dateTime).limit(3)

    @event1 = threeEvents.first
    @event2 = threeEvents.second
    @event3 = threeEvents.third

    @event1_image = !@event1.image_filepath.standard.nil? ? @event1.image_filepath.standard.to_s : 'default.jpg' if !@event1.nil?
    @event2_image = !@event2.image_filepath.standard.nil? ? @event2.image_filepath.standard.to_s : 'default.jpg' if !@event2.nil?
    @event3_image = !@event3.image_filepath.standard.nil? ? @event3.image_filepath.standard.to_s : 'default.jpg' if !@event3.nil?

    d1 = @event1.dateTime.to_s.match('\d{4}[-]\d{2}[-]\d{2}').to_s.split('-') if !@event1.nil?
    @date1 = d1[1] + "/" + d1[2] + "/" + d1[0] if !@event1.nil?
    d2 = @event2.dateTime.to_s.match('\d{4}[-]\d{2}[-]\d{2}').to_s.split('-') if !@event2.nil?
    @date2 = d2[1] + "/" + d2[2] + "/" + d2[0] if !@event2.nil?
    d3 = @event3.dateTime.to_s.match('\d{4}[-]\d{2}[-]\d{2}').to_s.split('-') if !@event3.nil?
    @date3 = d3[1] + "/" + d3[2] + "/" + d3[0] if !@event3.nil?

    @video1 = Video.first
    @video2 = Video.second
    @video3 = Video.third

    @album1 = Album.order(:release).first

    @products = Product.order(:release)
    @product1 = @products.first
    @product2 = @products.second
  end

  # GET /alohas/1
  # GET /alohas/1.json
  def show
    if !user_signed_in?
      redirect_to :root
    end
  end

  # GET /alohas/new
  def new
    if !user_signed_in?
      redirect_to :root
    else
      @aloha = Aloha.new
    end
  end

  # GET /alohas/1/edit
  def edit
    if !user_signed_in?
      redirect_to :root
    end
  end

  # POST /alohas
  # POST /alohas.json
  def create
    if !user_signed_in?
      redirect_to :root
    else
      @aloha = Aloha.new(aloha_params)

      respond_to do |format|
        if @aloha.save
          format.html { redirect_to @aloha, notice: 'Aloha was successfully created.' }
          format.json { render :show, status: :created, location: @aloha }
        else
          format.html { render :new }
          format.json { render json: @aloha.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /alohas/1
  # PATCH/PUT /alohas/1.json
  def update
    if !user_signed_in?
      redirect_to :root
    else
      respond_to do |format|
        if @aloha.update(aloha_params)
          format.html { redirect_to @aloha, notice: 'Aloha was successfully updated.' }
          format.json { render :show, status: :ok, location: @aloha }
        else
          format.html { render :edit }
          format.json { render json: @aloha.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /alohas/1
  # DELETE /alohas/1.json
  def destroy
    if !user_signed_in?
      redirect_to :root
    else
      @aloha.destroy
      respond_to do |format|
        format.html { redirect_to alohas_url, notice: 'Aloha was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_aloha
      @aloha = Aloha.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def aloha_params
      params.require(:aloha).permit(:name)
    end
  end

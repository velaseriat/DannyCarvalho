class SubscribersController < ApplicationController
  before_action :set_subscriber, only: [:show, :edit, :update, :destroy]


  def unsubscribe
    @thesubscriber = Subscriber.where(email: params[:subscriber_email]).first

  end
  # GET /subscribers
  # GET /subscribers.json
  def index
    if !user_signed_in?
      redirect_to :root
    else
      @subscribers = Subscriber.all
    end
  end

  # GET /subscribers/1
  # GET /subscribers/1.json
  def show
    if !user_signed_in?
      redirect_to :root
    end
  end

  # GET /subscribers/new
  def new
    @subscriber = Subscriber.new
  end

  # GET /subscribers/1/edit
  def edit
    if !user_signed_in?
      redirect_to :root
    end
  end

  # POST /subscribers
  # POST /subscribers.json
  def create
    @subscriber = Subscriber.new(subscriber_params)
    subb = Subscriber.where(email: @subscriber.email).first
    respond_to do |format|
      if !subb.nil?
        subb.opted_out = false
        subb.save
      else
        @subscriber.save
      end
      format.js { }
    end
  end

  # PATCH/PUT /subscribers/1
  # PATCH/PUT /subscribers/1.json
  def update
    if !user_signed_in? || @subscriber.nil?
      redirect_to :root
    else
      respond_to do |format|
        if @subscriber.update(subscriber_params)
          format.html { redirect_to @subscriber, notice: 'Subscriber was successfully updated.' }
          format.json { render :show, status: :ok, location: @subscriber }
        else
          format.html { render :edit }
          format.json { render json: @subscriber.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /subscribers/1
  # DELETE /subscribers/1.json
  def destroy
    if !user_signed_in?
      redirect_to :root
    else
      @subscriber.destroy
      respond_to do |format|
        format.js { }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscriber
      @subscriber = Subscriber.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subscriber_params
      params.require(:subscriber).permit(:email, :opted_out)
    end
end

class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @events = Event.where('dateTime > ?', DateTime.now).order(:dateTime)

    #@events = Event.all

    @event_sets = Array.new

    i = 0
    event_set = Array.new
    @events.each do |event|
      if i < 4
        event_set << event
        i = i + 1
      end
      if i >= 4
        @event_sets << event_set
        event_set = Array.new
        i = 0
      end
    end

  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    if !user_signed_in?
      redirect_to :root
    else
      @event = Event.new
    end
  end

  # GET /events/1/edit
  def edit
    if !user_signed_in?
      redirect_to :root
    end
  end

  # POST /events
  # POST /events.json
  def create
    if !user_signed_in?
      redirect_to :root
    else
      @event = Event.new(event_params)

      respond_to do |format|
        if @event.save
          format.html { redirect_to @event, notice: 'Event was successfully created.' }
          format.json { render :show, status: :created, location: @event }
        else
          format.html { render :new }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    if !user_signed_in?
      redirect_to :root
    else
      respond_to do |format|
        if @event.update(event_params)
          format.html { redirect_to @event, notice: 'Event was successfully updated.' }
          format.json { render :show, status: :ok, location: @event }
        else
          format.html { render :edit }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    if !user_signed_in?
      redirect_to :root
    else
      @event.destroy
      respond_to do |format|
        format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:summary, :dateTime, :endDateTime, :timeZone, :location, :description, :colorId, :image_filepath)
    end
  end

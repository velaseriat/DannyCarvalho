class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  require 'google/api_client'
  require 'open-uri'
  require 'instagram'
  require 'rufus-scheduler'
  require 'share-counter'

  def console
    if !user_signed_in?
      redirect_to :root
    else
      respond_to do |format|
        format.html { render 'console' }
      end
    end
  end

  def check_social_count
    if !user_signed_in?
      redirect_to :root
    else
      url = 'http://www.dannycarvalho.com'
      @counts = ShareCounter.all url
    end
    respond_to do |format|
      format.js { }
    end
  end

  def start_scheduler
    if !user_signed_in?
      redirect_to :root
    else
      if ENV['STARTED_SCHEDULER'] != 'start'
        ENV['STARTED_SCHEDULER'] = 'start'
      end
      respond_to do |format|
        format.html { redirect_to current_user }
      end
    end
  end

  def send_custom_emails
    if !user_signed_in?
      redirect_to :root
    else
      @event = Event.first
      Subscriber.all.each do |s|
        if !s.opted_out
          SubscriberMailer.send_custom_email(s, params[:custom_text]).deliver_later
        end
      end
      respond_to do |format|
        format.html { redirect_to current_user }
      end
    end
  end

  def update_instagram
    if !user_signed_in?
      redirect_to :root
    else
      Instagram.configure do |config|
        config.client_id = Rails.application.config.instagramClientID
        config.client_secret = Rails.application.config.instagramClientSecret
      end

      client = Instagram.client(access_token: Rails.application.config.instagramAccessToken)

      results = client.user_recent_media

      if !results.nil?
        if !results.first.nil?
          if !results.first.images.nil?
            results.each do |media|
              image_path = media.images.standard_resolution.url
              link = media.link
              text = media.caption.text if !media.caption.nil?
              dateTime = Time.at(media.created_time.to_i).iso8601


              i = Igram.where(link: link).first_or_initialize
              if i.image_path.thumbnail.to_s.empty?
                i.remote_image_path_url = image_path
              end

              i.link = link
              i.text = text
              i.dateTime = dateTime
              i.save
            end
          end
        end
      end
      respond_to do |format|
        format.html { redirect_to current_user }
      end
    end
  end

  def send_event_emails
    if !user_signed_in?
      redirect_to :root
    else
      @events = Array.new
      params[:selected_events].each do |se|
        @events << Event.find(se)
      end
      Subscriber.all.each do |s|
        if !s.opted_out
          SubscriberMailer.send_event_email(s, @events).deliver_later
        end
      end
      respond_to do |format|
        format.html { redirect_to current_user }
      end
    end
  end

  def update_events
    if !user_signed_in?
      redirect_to :root
    else
      updated = false
      starttime = DateTime.now.iso8601(2)


      puts "Updating at #{starttime}"

      client = Google::APIClient.new(:application_name => Rails.application.config.applicationName,
        :application_version => '0.1.0')
      key = Google::APIClient::KeyUtils.load_from_pkcs12(Rails.application.config.googleP12, Rails.application.config.googlePassphrase)

      client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience => 'https://accounts.google.com/o/oauth2/token',
        :scope => 'https://www.googleapis.com/auth/calendar',
        :issuer => Rails.application.config.googleIssuer,
        :signing_key => key)
      client.authorization.fetch_access_token!

      calendar_api = client.discovered_api('calendar', 'v3')

      results = client.execute!(
        :api_method => calendar_api.events.list,
        :parameters => {
          :calendarId => Rails.application.config.googleCalendarID,
          :orderBy => 'startTime',
          :maxResults => 30,
          :singleEvents => true,
          :timeMin => starttime
          })
      if !results.nil?
        if !results.data.nil?
          if !results.data.summary.nil?
            results.data.items.each do |item|
              summary = item.summary
              dateTime = item.start.dateTime
              location = item.location
              description = item.description

              if description.match('\[\[')
                image_filepath = description.match('\[\[\S+\]\]').to_s
                description.gsub!(image_filepath, '')
                image_filepath.gsub!('[[', '')
                image_filepath.gsub!(']]', '')
              end

              id = item.id
              #colorId = item.colorId

              #check if event already exists on database
              e = Event.where(event_id: id).first_or_initialize
              e.summary = summary
              e.dateTime = dateTime
              e.location = location
              e.description = description

              if e.image_filepath.file.nil?
                e.remote_image_filepath_url = image_filepath
              end

              if e.changed?
                e.save
              end
            end
          end
        end
      end

      respond_to do |format|
        format.html { redirect_to current_user }
      end
    end
  end

  def update_youtube
    if !user_signed_in?
      redirect_to :root
    else
      updated = false

      client = Google::APIClient.new(:application_name => Rails.application.config.applicationName,
        :application_version => '0.1.0')
      key = Google::APIClient::KeyUtils.load_from_pkcs12(Rails.application.config.googleP12, Rails.application.config.googlePassphrase)

      client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience => 'https://accounts.google.com/o/oauth2/token',
        :scope => 'https://www.googleapis.com/auth/youtube',
        :issuer => Rails.application.config.googleIssuer,
        :signing_key => key)
      client.authorization.fetch_access_token!

      yt = client.discovered_api('youtube', 'v3')

      results = client.execute!(
        :api_method => yt.search.list,
        :parameters => {
          :part => 'snippet',
          :q => 'Two Steps From Hell',
          :maxResults => 30,
          :channelId => 'UC3swwxiALG5c0Tvom83tPGg',
          :type => 'youtube#video',
          :order => 'date'
        }
        )

      video_ids = ""
      vid = Array.new

      puts "Channel Id: " + results.data.items[0].snippet.channelId
      results.data.items.each do |item|
        puts "--------------------------------"
        puts "Title: " + item.snippet.title
        puts "Description: " + item.snippet.description
        puts "Thumbnail: " + item.snippet.thumbnails.high.url
        puts "Video ID: " + item.id.videoId
        video_ids += item.id.videoId + ", "
        vid << item.id.videoId
      end


      results2 = client.execute!(
        :api_method => yt.videos.list,
        :parameters => {
          :part => 'snippet',
          :maxResults => 30,
          :id => video_ids
        }
        )


      if !results.nil?
        if !results.data.nil?
          if !results.data.items[0].nil?
            if results.data.items.size == results2.data.items.size
              update = true
              counter = 0
              results.data.items.each do |item|
                if item.id.kind == 'youtube#video'

                  v = Video.where(url_path: item.id.videoId).first_or_initialize

                  v.title = item.snippet.title
                  v.description = results2.data.items[counter].snippet.description
                  v.url_path = item.id.videoId
                  v.thumbnail_url = item.snippet.thumbnails.high.url
                  if v.changed?
                    v.save
                  end

                  counter = counter + 1
                end
              end
            end
          end
        end
      end


      respond_to do |format|
        if updated
          format.html { redirect_to current_user, notice: 'Events were successfully updated.' }
        else
          format.html { redirect_to current_user }
        end
      end
    end
  end

  def update_blogger
    if !user_signed_in?
      redirect_to :root
    else
      updated = false
      startTime = DateTime.now.iso8601(2)

      client = Google::APIClient.new(:application_name => Rails.application.config.applicationName,
        :application_version => '0.1.0')
      key = Google::APIClient::KeyUtils.load_from_pkcs12(Rails.application.config.googleP12, Rails.application.config.googlePassphrase)

      client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience => 'https://accounts.google.com/o/oauth2/token',
        :scope => 'https://www.googleapis.com/auth/blogger',
        :issuer => Rails.application.config.googleIssuer,
        :signing_key => key)
      client.authorization.fetch_access_token!

      blogger = client.discovered_api('blogger', 'v3')

      results = client.execute!(
        :api_method => blogger.posts.list,
        :parameters => {
          :blogId => '1909269607934960155',
          :maxResults => 10,
          :orderBy => 'published',
          :status => 'live',
          :view => 'READER'
        }
        )

      if !results.nil?
        if !results.data.nil?
          if !results.data.items[0].nil?
            update = true
            results.data.items.each do |item|
              b = Blog.where(blogUrl: item.url).first_or_initialize
              b.blogId = item.id
              b.published = item.published
              b.blogUrl = item.url
              b.title = item.title
              b.content = item.content
              b.save
            end

          end
        end
      end

      respond_to do |format|
        if updated
          format.html { redirect_to current_user, notice: 'Events were successfully updated.' }
        else
          format.html { redirect_to current_user }
        end
      end
    end
  end

  def update_about
    if !user_signed_in?
      redirect_to :root
    else
      client = Google::APIClient.new(:application_name => Rails.application.config.applicationName,
        :application_version => '0.1.0')
      key = Google::APIClient::KeyUtils.load_from_pkcs12(Rails.application.config.googleP12, Rails.application.config.googlePassphrase)

      client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience => 'https://accounts.google.com/o/oauth2/token',
        :scope => 'https://www.googleapis.com/auth/blogger',
        :issuer => Rails.application.config.googleIssuer,
        :signing_key => key)
      client.authorization.fetch_access_token!

      blogger = client.discovered_api('blogger', 'v3')

      results = client.execute!(
        :api_method => blogger.pages.get,
        :parameters => {
          :blogId => '5193859969315643642',
          :pageId => '412588053249616065'
        }
        )

      if !results.nil?
        if !results.data.nil?
          if !results.data.content.nil?
            Aloha.delete_all
            content = results.data.content
            Aloha.create content: content, name: 'E Komo Mai!'
          end
        end
      end

      respond_to do |format|
        format.html { redirect_to current_user }
      end
    end
  end

  # GET /users
  # GET /users.json
  def index
    if !user_signed_in?
      redirect_to :root
    else
      @users = User.all
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if !user_signed_in?
      redirect_to :root
    else
      @events = Event.where('dateTime > ?', DateTime.now).order(:dateTime)
    end
  end

  # GET /users/new
  def new
    if !user_signed_in?
      redirect_to :root
    else
      @user = User.new
    end
  end

  # GET /users/1/edit
  def edit
    if !user_signed_in?
      redirect_to :root
    end
  end

  # POST /users
  # POST /users.json
  def create
    if !user_signed_in?
      redirect_to :root
    else
      @user = User.new(user_params)

      respond_to do |format|
        if @user.save
          format.html { redirect_to @user, notice: 'User was successfully created.' }
          format.json { render :show, status: :created, location: @user }
        else
          format.html { render :new }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if !user_signed_in?
      redirect_to :root
    else
      respond_to do |format|
        if @user.update(user_params)
          format.html { redirect_to @user, notice: 'User was successfully updated.' }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    if !user_signed_in?
      redirect_to :root
    else
      @user.destroy
      respond_to do |format|
        format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :uploader)
    end
  end

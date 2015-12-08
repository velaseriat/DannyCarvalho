class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  require 'google/api_client'
  require 'open-uri'
  require 'instagram'

  def update_social
    if !user_signed_in?
      redirect_to :root
    else
      require 'soundcloud'
      #require 'tumblr'
      require 'twitter'
      
      #soundcloud
      sc_client           = Soundcloud.new(client_id: Rails.application.config.soundcloudClientID)
      sc_track            = sc_client.get('/tracks', limit: 1,  user_id: 44982439).first
      soundcloud_id       = sc_track.id

      #instgram
      Instagram.configure do |config|
        config.client_id      = Rails.application.config.instagramClientID
        config.client_secret  = Rails.application.config.instagramClientSecret
      end
      ig_client           = Instagram.client(access_token: Rails.application.config.instagramAccessToken)
      ig_results          = ig_client.user_recent_media
      instagram_id        = ig_results.first.link

      #youtube
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
          :maxResults => 1,
          :q => 'Danny Carvalho'
        }
        )

      youtube_id = results.data.items[0].id.videoId

      #twitter
      tw_client           = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.config.twitterConsumerKey
        config.consumer_secret     = Rails.application.config.twitterConsumerSecret
        config.access_token        = Rails.application.config.twitterAccessToken
        config.access_token_secret = Rails.application.config.twitterAccessTokenSecret
      end
      tw_tweet            = tw_client.user_timeline("DannyICarvalho").first
      twitter_id          = tw_tweet.id

      #tumblr
      #tb_user             = Tumblr::User.new('velaseriat@outlook.com', Rails.application.config.tumblrPassword)
      #Tumblr.blog         = "just--space"
      #tb_posts            = Tumblr::Post.all
      #tumblr_id           = tb_posts.first['id']


      @aloha = Aloha.first
      @aloha.soundcloud_id  = soundcloud_id
      @aloha.instagram_id   = instagram_id
      @aloha.youtube_id     = youtube_id
      @aloha.twitter_id     = twitter_id
      #@aloha.tumblr_id      = tumblr_id

      @aloha.save


      respond_to do |format|
        format.html { redirect_to current_user }
      end
    end
  end

  def check_social_count
    if !user_signed_in?
      redirect_to :root
    else
      require 'share-counter'
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
      require 'platform-api'
      heroku = PlatformAPI.connect_oauth(Rails.application.config.herokuAuthToken)
      heroku.formation.update(Rails.application.config.herokuAppName, 'worker', {'quantity' => 1})
      if ENV['STARTED_SCHEDULER'] != 'start'
        ENV['STARTED_SCHEDULER'] = 'start'
      end
      respond_to do |format|
        format.html { redirect_to current_user }
      end
    end
  end

  def turn_on_mailer
    require 'platform-api'
    heroku = PlatformAPI.connect_oauth(Rails.application.config.herokuAuthToken)
    heroku.formation.update(Rails.application.config.herokuAppName, 'worker', {'quantity' => 1})
  end

  def send_custom_emails
    if !user_signed_in?
      redirect_to :root
    else
      @event = Event.first

      turn_on_mailer

      Subscriber.all.each do |s|
        if !s.opted_out
          SubscriberMailer.send_custom_email(s, params[:custom_text]).deliver_later
        end
      end

      SubscriberMailer.turn_off_mailer.deliver_later

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
    require 'platform-api'

    if !user_signed_in?
      redirect_to :root
    else
      @events = Array.new
      params[:selected_events].each do |se|
        @events << Event.find(se)
      end

      #please for the love of god fix this
      turn_on_mailer

      Subscriber.all.each do |s|
        if !s.opted_out
          SubscriberMailer.send_event_email(s, @events).deliver_later
        end
      end

      SubscriberMailer.turn_off_mailer.deliver_later
      
      respond_to do |format|
        format.html { redirect_to current_user }
      end
    end
  end

  # def update_news
  #   if !user_signed_in?
  #     redirect_to :root
  #   else
  #     updated = false
  #     starttime = DateTime.now.iso8601(2)


  #     puts "Updating at #{starttime}"

  #     client = Google::APIClient.new(:application_name => Rails.application.config.applicationName,
  #       :application_version => '0.1.0')
  #     key = Google::APIClient::KeyUtils.load_from_pkcs12(Rails.application.config.googleP12, Rails.application.config.googlePassphrase)

  #     client.authorization = Signet::OAuth2::Client.new(
  #       :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  #       :audience => 'https://accounts.google.com/o/oauth2/token',
  #       :scope => 'https://www.googleapis.com/auth/cse',
  #       :issuer => Rails.application.config.googleIssuer,
  #       :signing_key => key)
  #     client.authorization.fetch_access_token!

  #     cse_api = client.discovered_api('customsearch', 'v1')

  #     results = client.execute!(
  #       :api_method => cse_api.cse.list,
  #       :parameters => {
  #         :maxResults => 30,
  #         :q => "Danny Carvalho",
  #         :cx => "016987149122176185005:p6cpu5owsug",
  #         :dateRestrict => 'm6'
  #         })

  #     if !results.nil?
  #       if !results.data.nil?
  #         if !results.data.items.nil?
  #           results.data.items.each do |item|
  #             title = item.title
  #             link = item.link
  #             snippet = item.snippet

  #             #check if event already exists on database
  #             e = Article.where(title: title).first_or_initialize
  #             e.title = title
  #             e.link = link
  #             e.snippet = snippet

  #             if e.image_filepath.file.nil?
  #               e.remote_image_filepath_url = image_filepath
  #             end

  #             if e.changed?
  #               e.save
  #             end
  #           end
  #         end
  #       end
  #     end

  #     respond_to do |format|
  #       format.html { redirect_to current_user }
  #     end
  #   end
  # end

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

      puts "Using THIS: #{Rails.application.config.googleCalendarID}"

      results = client.execute!(
        :api_method => calendar_api.events.list,
        :parameters => {
          :maxResults => 30,
          :calendarId => Rails.application.config.googleCalendarID,
          :orderBy => 'startTime',
          :singleEvents => true,
          :timeMin => starttime
          })
      if !results.nil?
        if !results.data.nil?
          if !results.data.items.nil?
            results.data.items.each do |item|
              puts item
              summary = item.summary
              dateTime =  item.start.date.nil? ? item.start.dateTime : item.start.date
              endDateTime =  item.end.date.nil? ? item.end.dateTime : item.end.date
              location = item.location
              description = item.description.nil? ? "" : item.description

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
              e.endDateTime = endDateTime
              e.location = location
              e.description = description
              e.event_id = id

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

      # @events = Event.where('dateTime > ?', DateTime.now).order(:dateTime)
      # @events.each do |eve|
      #   if (((Time.zone.now - eve.updated_at)*24).to_i > 2)
      #     eve.destroy
      #   end
      # end

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
          :maxResults => 30,
          :channelId => 'UCU4UPkCWJk98Wi6Dr9AWqMA',
          :type => 'youtube#video',
          :order => 'date'
        }
        )

      video_ids = ""
      vid = Array.new

      puts "Channel Id: " + results.data.items[0].snippet.channelId
        results.data.items.each do |item|
          if item.id.kind == 'youtube#video'
            puts "--------------------------------"
            puts "Title: " + item.snippet.title
            puts "Description: " + item.snippet.description
            puts "Thumbnail: " + item.snippet.thumbnails.high.url
            puts "Video ID: " + item.id.videoId
            video_ids += item.id.videoId + ", "
            vid << item.id.videoId
          end
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
              update = true
              counter = 0
              results.data.items.each do |item|
                if item.id.kind == 'youtube#video'
                  v = Video.where(url_path: item.id.videoId).first_or_initialize

                  v.title = item.snippet.title

                  results2.data.items.each do |r2|
                    if item.id.videoId == r2.id
                      v.description = r2.snippet.description
                    end
                  end

                  v.url_path = item.id.videoId
                  v.thumbnail_url = item.snippet.thumbnails.high.url
                  v.save

                  counter = counter + 1
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

  # def update_about
  #   if !user_signed_in?
  #     redirect_to :root
  #   else
  #     client = Google::APIClient.new(:application_name => Rails.application.config.applicationName,
  #       :application_version => '0.1.0')
  #     key = Google::APIClient::KeyUtils.load_from_pkcs12(Rails.application.config.googleP12, Rails.application.config.googlePassphrase)

  #     client.authorization = Signet::OAuth2::Client.new(
  #       :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  #       :audience => 'https://accounts.google.com/o/oauth2/token',
  #       :scope => 'https://www.googleapis.com/auth/blogger',
  #       :issuer => Rails.application.config.googleIssuer,
  #       :signing_key => key)
  #     client.authorization.fetch_access_token!

  #     blogger = client.discovered_api('blogger', 'v3')

  #     results = client.execute!(
  #       :api_method => blogger.pages.get,
  #       :parameters => {
  #         :blogId => '5193859969315643642',
  #         :pageId => '412588053249616065'
  #       }
  #       )

  #     if !results.nil?
  #       if !results.data.nil?
  #         if !results.data.content.nil?
  #           Aloha.delete_all
  #           content = results.data.content
  #           Aloha.create content: content, name: 'E Komo Mai!'
  #         end
  #       end
  #     end

  #     respond_to do |format|
  #       format.html { redirect_to current_user }
  #     end
  #   end
  # end

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

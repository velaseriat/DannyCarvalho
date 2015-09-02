#
# config/initializers/scheduler.rb

require 'rufus-scheduler'
require 'google/api_client'
require 'instagram'
# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton
#@event = Event.first
def update_instagram
  
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
end

def update_events
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

      @events = Event.where('dateTime > ?', DateTime.now).order(:dateTime)
      @events.each do |eve|
        if (((DateTime.now - eve.update_at)*24).to_i > 2)
          eve.destroy
        end
      end
end


def update_youtube
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

def update_blogger
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
end

def update_about
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
end




def update_social
  require 'soundcloud'
  require 'tumblr'
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

  #twitter
  tw_client           = Twitter::REST::Client.new do |config|
    config.consumer_key        = Rails.application.config.twitterConsumerKey
    config.consumer_secret     = Rails.application.config.twitterConsumerSecret
    config.access_token        = Rails.application.config.twitterAccessToken
    config.access_token_secret = Rails.application.config.twitterAccessTokenSecret
  end
  tw_tweet            = tw_client.user_timeline.first
  twitter_id          = tw_tweet.id

  #tumblr
  tb_user             = Tumblr::User.new('velaseriat@outlook.com', Rails.application.config.tumblrPassword)
  Tumblr.blog         = "just--space"
  tb_posts            = Tumblr::Post.all
  tumblr_id           = tb_posts.first['id']


  @aloha = Aloha.first
  @aloha.soundcloud_id  = soundcloud_id
  @aloha.instagram_id   = instagram_id
  @aloha.youtube_id     = Video.first
  @aloha.twitter_id     = twitter_id
  @aloha.tumblr_id      = tumblr_id

  @aloha.save
end


s.every '6h' do
  if ENV['START_SCHEDULER'] = 'start'
    update_events
    update_blogger
    update_about
    update_youtube
    update_instagram
    puts "Updated at at: #{Time.now}"
  end
end

s.every '1h' do
  if ENV['START_SCHEDULER'] = 'start'
    update_social
    puts "Updated Social at at: #{Time.now}"
  end
end
#
# config/initializers/scheduler.rb

require 'rufus-scheduler'
require 'google/api_client'
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
            ifilename = media.created_time + image_path.match('\.(?:jpg|png|gif|jpeg|bmp|JPG|PNG|GIF|JPEG|BMP)$').to_s
            File.open(File.join(Rails.root, "public/igrams/images/" + ifilename), 'wb') do |fo|
              fo.write open(image_path).read 
            end

            if File.exist? File.open(File.join(Rails.root, "public/igrams/images/" + ifilename))
              i.image_path = File.open(File.join(Rails.root, "public/igrams/images/" + ifilename))
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
    checkImage = false
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
            checkImage = false
            summary = item.summary
            dateTime = item.start.dateTime
            location = item.location
            description = item.description

            if description.match('\[\[')
              image_filepath = description.match('\[\[\S+\]\]').to_s
              description.gsub!(image_filepath, '')
              image_filepath.gsub!('[[', '')
              image_filepath.gsub!(']]', '')
              checkImage = true
            end

            id = item.id
            #colorId = item.colorId

            #check if event already exists on database
            e = Event.where(event_id: id).first_or_initialize
            e.summary = summary
            e.dateTime = dateTime
            e.location = location
            e.description = description
            
            if e.image_filepath.file.nil? && checkImage

                filename = item.id + image_filepath.match('\.(?:jpg|png|gif|jpeg|bmp|JPG|PNG|GIF|JPEG|BMP)$').to_s
                File.open(File.join(Rails.root, "public/images/" + filename), 'wb') do |fo|
                  fo.write open(image_filepath).read 
                end
                if File.exist? File.open(File.join(Rails.root, "public/images/" + filename))
                  e.image_filepath = File.open(File.join(Rails.root, "public/images/" + filename))
                end
            end
            
            if e.changed?
              e.save
            end
          end
        end
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
        :blogId => '1756045714671751226',
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
s.every '8h' do
	if Rails.application.config.googleCalendarID
		update_events
    update_blogger
    update_about
    update_youtube
    update_instagram
 		puts "Sent emails at: #{Time.now}"
 	end
end
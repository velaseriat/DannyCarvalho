Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  config.time_zone = 'Hawaii'


  @avanti = Hash.new

  if File.exists?('credentials.avanti')
    file = File.open('credentials.avanti', 'r')
    puts "============================================================="
      puts "Your development keys:"
    file.each do |line|
      line.chomp!
      linedata = line.split(':::')
      @avanti[linedata[0]] = linedata[1]
      puts linedata[0] + '  ' + @avanti[linedata[0]]
    end
    puts "============================================================="
  end

  config.applicationName = @avanti["applicationName"].to_s
  config.googleP12 = @avanti["googleP12"].to_s
  config.googlePassphrase = @avanti["googlePassphrase"].to_s
  config.googleIssuer = @avanti["googleIssuer"].to_s
  config.googleCalendarID = @avanti["googleCalendarID"].to_s
  config.googleMapKey = @avanti["googleMapKey"].to_s

  #config.twitterConsumerKey = @avanti["twitterConsumerKey"].to_s
  #config.twitterConsumerSecret = @avanti["twitterConsumerSecret"].to_s
  #config.twitterAccessToken = @avanti["twitterAccessToken"].to_s
  #config.twitterAccessTokenSecret = @avanti["twitterAccessTokenSecret"].to_s

  config.instagramClientID = @avanti["instagramClientID"].to_s
  config.instagramClientSecret = @avanti["instagramClientSecret"].to_s
  config.instagramClientRedirectURI = @avanti["instagramClientRedirectURI"].to_s
  config.instagramAccessToken = @avanti["instagramAccessToken"].to_s


  #config.facebookAppID = @avanti["facebookAppID"].to_s
  #config.facebookAppSecret = @avanti["facebookAppSecret"].to_s
  #config.facebookAppToken = @avanti["facebookAppToken"].to_s
  #config.facebookAccessToken = @avanti["facebookAccessToken"].to_s

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              @avanti["emailAddress"],
    port:                 587,
    domain:               @avanti["emailDomain"],
    user_name:            @avanti["emailUserName"],
    password:             @avanti["emailPassword"],
    authentication:       'plain',
    enable_starttls_auto: true  }

end
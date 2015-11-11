class SubscriberMailer < ActionMailer::Base
  default from: "mailman@dannycarvalho.com"

  def send_event_email(subscriber, events)
  	@subscriber = subscriber
  	@events = events
    mail to: subscriber.email, subject: "Danny Carvalho Newsletter - Upcoming Event"
  end

  def send_custom_email(subscriber, text)
    @subscriber = subscriber
  	@text = text
  	mail to: subscriber.email, subject: "Danny Carvalho Newsletter"
  end

  def turn_off_mailer
    require 'platform-api'
    heroku = PlatformAPI.connect_oauth(Rails.application.config.herokuAuthToken)
    heroku.formation.update(Rails.application.config.herokuAppName, 'worker', {'quantity' => 0})
  end
end
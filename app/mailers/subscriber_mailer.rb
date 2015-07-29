class SubscriberMailer < ActionMailer::Base
  default from: "mailman@dannycarvalho.com"

  def email_events(subscriber, events)
  	@subscriber = subscriber
  	@events = events
    mail to: subscriber.email, subject: "Danny Carvalho Newsletter - Upcoming Event"
  end

  def send_custom_email(subscriber, text)
    @subscriber = subscriber
  	@text = text
  	mail to: subscriber.email, subject: "Danny Carvalho Newsletter"
  end
end
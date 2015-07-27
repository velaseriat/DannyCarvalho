class SubscriberMailer < ActionMailer::Base
  default from: "mailman@dannycarvalho.com"

  def new_event(subscriber, event)
  	@subscriber = subscriber
  	@event = event
    mail to: subscriber.email, subject: "Aloha!"
  end

  def send_custom_email(subscriber, text)
    @subscriber = subscriber
  	@text = text
  	mail to: subscriber.email, subject: "THE TEST TEXT!"
  end
end
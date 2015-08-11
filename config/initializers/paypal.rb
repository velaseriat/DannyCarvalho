if File.exists?('paypal.avanti')
	PayPal::SDK.load('paypal.avanti', Rails.env)
	PayPal::SDK.logger = Rails.logger
end
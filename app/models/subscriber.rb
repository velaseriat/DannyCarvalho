class Subscriber < ActiveRecord::Base
	validates :email, :presence => true, :email => true
	validates_uniqueness_of :email
	before_save :set_opted_out

	def set_opted_out
		if self.opted_out.nil?
			self.opted_out = 0
			self.save
		end
	end

end

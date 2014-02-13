module Mundipagg	
	# Class that hold recurrency transaction information
	class Recurrency

		# @return [Date] Date the first recurrency will be charged.
		attr_accessor :dateToStartBilling
		
		# @return [String] Indicating the recurrency frequency.
		# @see FrequencyEnum
		attr_accessor :frequencyEnum

		# @return [Integer] Recurrency interval.
		attr_accessor :interval
		
		# @return [Boolean] Indicates whether the One webservice will run an OneDollarAuth 
		# to validate the credit card.
		attr_accessor :oneDollarAuth
		
		# @return [Integer] Number of recurrencies.
		attr_accessor :recurrences

		# Allowed recurrency frequency
		@@FREQUENCY = {
			:Monthly => 'Monthly',
			:Yearly => 'Yearly',
			:Daily => 'Daily'
		}

		# Initialize class and properties
		def initialize	
		end

		# Allowed recurrency frequency
		def self.FrequencyEnum
                  @@FREQUENCY
		end
	end
end

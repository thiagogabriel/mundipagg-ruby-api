class BoletoTransaction
	attr_accessor :amountInCents, :bankNumber, :daysToAddInBoletoExpirationDate, 
					:nossoNumero, :instructions, :transactionReference


	def initialize
		@amountInCents = 0
	end
	
	
end
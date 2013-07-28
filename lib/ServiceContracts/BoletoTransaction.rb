class BoletoTransaction

	# @return [Long] Transaction amount in cents
	attr_accessor :amountInCents 
	
	# @return [Integer] Bank code
	attr_accessor :bankNumber
	
	# @return [Integer] How many days after the creation the boleto will be valid.
	# @param Default: 7 
	attr_accessor :daysToAddInBoletoExpirationDate 
	
	# @return [Integer] Number used to identify the boleto	
	attr_accessor :nossoNumero 
	
	# @return [Long] Text with payment instructions. Limit: 120 characters.
	attr_accessor :instructions
	
	# @return [Long] Custom transaction identifier.
	attr_accessor :transactionReference

	# Initialize class with default values
	def initialize
		@amountInCents = 0
		@daysToAddInBoletoExpirationDate = 7
	end
	
	
end
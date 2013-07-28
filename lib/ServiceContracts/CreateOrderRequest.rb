class CreateOrderRequest
	# @return [Long] Order amount in cents
	attr_accessor :amountInCents

	# @return [Long] Amount (in cents) to consider the order is paid
	attr_accessor :amountInCentsToConsiderPaid
	
	# @return [String] Order amount currency.
	# @param Default: BRL
	# @see CurrencyIsoEnum
	attr_accessor :currencyIsoEnum 
	
	# @return [Buyer] Buyer instance
	# @see Buyer
	attr_accessor :buyer 
	
	# @return [Guid] MundiPagg merchant identification 
	attr_accessor :merchantKey 
	
	# If merchant not send OrderReference, Mundipagg will generate and return in the response.
	# @return [String] Custom order identification.
	attr_accessor :orderReference
	
	# @return [Array] Array with all credit card transactions 
	attr_accessor :creditCardTransactionCollection 
	
	# @return [Array] Array with all boleto transactions
	attr_accessor :boletoTransactionCollection
	
	# If not send, it will be generate automatically in the webservice and returned in response.
	# Web service request identification, it is used for investigate problems with webservice requests.
	# @return [Guid] Globally Unique Identifier. 
	# @param Optional
	# @param Default: 00000000-0000-0000-0000-000000000000
	attr_accessor :requestKey

	# Currency Enum
	# @returns [Hash<Symbol, String>]
	@@CURRENCY_ISO ={
		:BrazillianReal => 'BRL',
		:AmericanDollar => 'USD'
	}

	# Initialize class and properties
    def initialize
		@creditCardTransactionCollection = Array.new;
		@boletoTransactionCollection = Array.new;
		@currencyIsoEnum = CreateOrderRequest.CurrencyIsoEnum[:BrazillianReal]
		@requestKey = '00000000-0000-0000-0000-000000000000'

	end

	# Currency Enum
	# @returns [Hash<Symbol, String>]
	# @see @@CURRENCY_ISO
	def self.CurrencyIsoEnum
		@@CURRENCY_ISO
	end

end
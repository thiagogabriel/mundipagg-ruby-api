class CreateOrderRequest
	attr_accessor :amountInCents, :amountInCentsToConsiderPaid, :currencyIsoEnum, :buyer, 
					:merchantKey, :orderReference, :creditCardTransactionCollection, 
					:boletoTransactionCollection, :requestKey


	@@CurrencyISO ={
		:BrazillianReal => 'BRL',
		:AmerianDollar => 'USD'
	}

    def initialize
		@creditCardTransactionCollection = [];
		@boletoTransactionCollection = [];
		@currencyIsoEnum = CreateOrderRequest.CurrencyIsoEnum[:BrazillianReal]
		@requestKey = '00000000-0000-0000-0000-000000000000'

	end

	def self.CurrencyIsoEnum
		@@CurrencyISO
	end

end
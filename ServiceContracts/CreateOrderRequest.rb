class CreateOrderRequest
	attr_accessor :amountInCents, :amountInCentsToConsiderPaid, :currencyIsoEnum, :buyer,
					:merchantKey, :orderReference, :creditCardTransactionCollection, :boletoTransactionCollection 


	@@CurrencyISO ={
		:BrazillianReal => 'BRL',
		:AmerianDollar => 'USD'
	}

    def initialize
		@creditCardTransactionCollection = [];
		@boletoTransactionCollection = [];
		@currencyIsoEnum = CreateOrderRequest.CurrencyIsoEnum[:BrazillianReal]
	end

	def self.CurrencyIsoEnum
		@@CurrencyISO
	end

end
class CreateOrderRequest
	attr_accessor :amountInCents, :amountInCentsToConsiderPaid, :currencyIsoEnum,
					:merchantKey, :orderReference, :creditCardTransactionCollection, :boletoTransactionCollection 

    def initialize
		@creditCardTransactionCollection = [];
		@boletoTransactionCollection = [];
		@currencyIsoEnum = 'BRL'
	end

end
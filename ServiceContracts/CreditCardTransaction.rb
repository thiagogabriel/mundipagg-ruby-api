class CreditCardTransaction
	attr_accessor :amountInCents, :creditCardBrandEnum, :creditCardNumber, :creditCardOperationEnum,
					:expirationMonth, :expirationYear, :holderName, :installmentCount, :securityCode,
					:paymentMethodCode, :transactionReference

	@@CardBrand = {
		:Visa => 'Visa',
		:Mastercard => 'Mastercard',
		:AmericanExpress => 'Amex',
		:Hipercard => 'Hipercard',
		:Diners => 'Diners',
		:Elo => 'Elo',
		:Aura => 'Aura',
		:Discover => 'Discover'
	}

	@@Operation = {
		:AuthOnly => 'AuthOnly',
		:AuthAndCapture => 'AuthAndCapture',
		:AuthAndCaptureWithDelay => 'AuthAndCaptureWithDelay'
	}

	def self.BrandEnum
		@@CardBrand
	end

	def self.OperationEnum
		@@Operation
	end
end
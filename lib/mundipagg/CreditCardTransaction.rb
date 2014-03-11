module Mundipagg
	class CreditCardTransaction
		
		# @return [Long] Transaction amount in cents
		attr_accessor :amountInCents

                # @return [String] Instant buy key
		attr_accessor :instantBuyKey
          
		# @return [String] Card brand. Use the static property <i>BrandEnum</i>.
		# @see BrandEnum
		attr_accessor :creditCardBrandEnum 
		
		# @return [String] Credit Card Number.
		attr_accessor :creditCardNumber
		
		# @return [String] Type of operation. Use the static property <i>OperationEnum</i>.
		# @see OperationEnum
		attr_accessor :creditCardOperationEnum
		
		# @return [Integer] Credit card expiration month
		attr_accessor :expirationMonth 
		
		# @return [Integer] Credit card expiration year
		attr_accessor :expirationYear 
		
		# @return [Integer] Name in the credit card
		attr_accessor :holderName
		
		# @return [Integer] Transaction installments count. 
		attr_accessor :installmentCount 
		
		# @return [Integer] Card security code.
		attr_accessor :securityCode
		
		# @return [Integer] Code to select the payment method. Can be <i>Cielo<i>, <i>Redecard<i> and others. 
		attr_accessor :paymentMethodCode 
		
		# @return [String] Custom transaction identifier.
		attr_accessor :transactionReference

		# Fill this property when creating a recurrency transaction. 
		# @return [Recurrency] Transaction recurrency information.
		attr_accessor :recurrency

		# Allowed card brands 
		# @returns [Hash<Symbol, String>] 
		@@CARD_BRAND = {
			:Visa => 'Visa',
			:Mastercard => 'Mastercard',
			:AmericanExpress => 'Amex',
			:Hipercard => 'Hipercard',
			:Diners => 'Diners',
			:Elo => 'Elo',
			:Aura => 'Aura',
			:Discover => 'Discover'
		}

		# Types of operation.
		# @returns [Hash<Symbol, String>] 
		@@OPERATION = {
			:AuthOnly => 'AuthOnly',
			:AuthAndCapture => 'AuthAndCapture',
			:AuthAndCaptureWithDelay => 'AuthAndCaptureWithDelay'
		}

		# Allowed card brands 
		# @returns [Hash<Symbol, String>] 
		# @see @@CARD_BRAND
		def self.BrandEnum
			@@CARD_BRAND
		end

		# Allowed operations.
		# @returns [Hash<Symbol, String>] 
		# @see @@OPERATION
		def self.OperationEnum
			@@OPERATION
		end
	end
end

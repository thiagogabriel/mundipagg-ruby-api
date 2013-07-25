require 'Savon'
require_relative 'ServiceContracts/CreateOrderRequest.rb'
require_relative 'ServiceContracts/BoletoTransaction.rb'
require_relative 'ServiceContracts/CreditCardTransaction.rb'

class MundiPaggClient

	def initialize
		
	end

	def SendOrder(request)
		
		parser = Nori.new(:convert_tags_to => lambda { |tag| tag })
		hash = parser.parse('
		         <tns:createOrderRequest>
		            <mun:AmountInCents>?</mun:AmountInCents>
		            <mun:AmountInCentsToConsiderPaid>?</mun:AmountInCentsToConsiderPaid>		            
		            <mun:CurrencyIsoEnum>?</mun:CurrencyIsoEnum>		            
		            <mun:MerchantKey>?</mun:MerchantKey>		            
		            <mun:OrderReference>?</mun:OrderReference>
		            <mun:CreditCardTransactionCollection>
		            </mun:CreditCardTransactionCollection>		            
		            <mun:BoletoTransactionCollection>
		            </mun:BoletoTransactionCollection>
		         </tns:createOrderRequest>')

		xml_hash = hash['tns:createOrderRequest'];

		xml_hash['mun:AmountInCents'] = request.amountInCents
		xml_hash['mun:AmountInCentsToConsiderPaid'] = request.amountInCentsToConsiderPaid
		xml_hash['mun:CurrencyIsoEnum'] = request.currencyIsoEnum
		xml_hash['mun:MerchantKey'] = request.merchantKey
		xml_hash['mun:OrderReference'] = request.orderReference

		if request.creditCardTransactionCollection.count > 0
			#Create credit card transaction array and assing to the contract hash		
			creditCardTransactionCollection = CreateCreditCardTransaction(request)
			xml_hash['mun:CreditCardTransactionCollection'] = creditCardTransactionCollection
		end

		if request.boletoTransactionCollection.count > 0
			#Create boleto transaction array and assing to the contract hash
			boletoTransactionCollection = CreateBoletoTransactionRequest(request);
			xml_hash['mun:BoletoTransactionCollection'] = boletoTransactionCollection
		end

		client = Savon.client do
			wsdl "https://transaction.mundipaggone.com/MundiPaggService.svc?wsdl"
			namespaces "xmlns:mun" => "http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts"
		end

		response = client.call(:create_order, message: hash)


		return response

	end

	def CreateBoletoTransactionRequest(boletoRequest)

		transactionCollection = {'mun:BoletoTransaction' => Array.new}

		boletoRequest.boletoTransactionCollection.each do |boleto| 

			transactionCollection['mun:BoletoTransaction'] << {
					'mun:AmountInCents' => boleto.amountInCents,
					'mun:BankNumber' => boleto.bankNumber, 
					'mun:DaysToAddInBoletoExpirationDate' => boleto.daysToAddInBoletoExpirationDate, 
					'mun:Instructions' => boleto.instructions, 
					'mun:NossoNumero' => boleto.nossoNumero,
					'mun:TransactionReference' => boleto.transactionReference,

			}

		end

		return transactionCollection

	end

	def CreateCreditCardTransaction(creditCardRequest)

		transactionCollection = {'mun:CreditCardTransaction' => Array.new}

		creditCardRequest.creditCardTransactionCollection.each do |transaction| 

			transactionCollection['mun:CreditCardTransaction'] << {
					'mun:AmountInCents' => transaction.amountInCents,
					'mun:CreditCardBrandEnum' => transaction.creditCardBrandEnum.to_s, 
					'mun:CreditCardNumber' => transaction.creditCardNumber, 
					'mun:CreditCardOperationEnum' => transaction.creditCardOperationEnum.to_s, 
					'mun:ExpMonth' => transaction.expirationMonth,
					'mun:ExpYear' => transaction.expirationYear,
					'mun:HolderName' => transaction.holderName,
					'mun:InstallmentCount' => transaction.installmentCount,
					'mun:PaymentMethodCode' => transaction.paymentMethodCode,
					'mun:SecurityCode' => transaction.securityCode,
					'mun:TransactionReference' => transaction.transactionReference
			}
		end

		return transactionCollection
	end

	private :CreateBoletoTransactionRequest, :CreateCreditCardTransaction
end
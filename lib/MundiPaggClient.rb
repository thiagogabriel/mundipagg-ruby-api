require 'Savon'
require_relative 'ServiceContracts/CreateOrderRequest.rb'
require_relative 'ServiceContracts/BoletoTransaction.rb'
require_relative 'ServiceContracts/CreditCardTransaction.rb'
require_relative 'ServiceContracts/Buyer.rb'
require_relative 'ServiceContracts/QueryOrderRequest.rb'
require_relative 'ServiceContracts/ManagerOrderRequest.rb'

class MundiPaggClient

	attr_reader :parser

  def initialize
  	@parser = Nori.new(:convert_tags_to => lambda { |tag| tag })
  end

  def ManagerOrder(request)

	hash = @parser.parse('<tns:manageOrderRequest>
							<mun:ManageCreditCardTransactionCollection>
							</mun:ManageCreditCardTransactionCollection>
							<mun:ManageOrderOperationEnum>?</mun:ManageOrderOperationEnum>
							<mun:MerchantKey>?</mun:MerchantKey>
							<mun:OrderKey>?</mun:OrderKey>
							<mun:OrderReference>?</mun:OrderReference>
							<mun:RequestKey>?</mun:RequestKey>
						</tns:manageOrderRequest>')

	xml_hash = hash['tns:manageOrderRequest'];

	xml_hash['mun:ManageCreditCardTransactionCollection'] = {'mun:ManageCreditCardTransactionRequest'=>Array.new}

	if request.transactionCollection.nil? == false and request.transactionCollection.count > 0
		
		request.transactionCollection.each do |transaction|
			
			xml_hash['mun:ManageCreditCardTransactionCollection']['mun:ManageCreditCardTransactionRequest'] << {
				'mun:AmountInCents' => transaction.amountInCents, 
				'mun:TransactionKey' => transaction.transactionKey, 
				'mun:TransactionReference' => transaction.transactionReference 
			}
		end 
	end

	xml_hash['mun:ManageOrderOperationEnum'] = request.manageOrderOperationEnum
	xml_hash['mun:MerchantKey'] = request.merchantKey
	xml_hash['mun:OrderKey'] = request.orderKey
	xml_hash['mun:OrderReference'] = request.orderReference
	xml_hash['mun:RequestKey'] = request.requestKey

	response = SendToService(hash, :manage_order)

	return response

	end

  def QueryOrder(request)

    parser = Nori.new(:convert_tags_to => lambda { |tag| tag })

    hash = parser.parse("<tns:queryOrderRequest>
				<mun:MerchantKey>?</mun:MerchantKey>
				<mun:OrderKey>?</mun:OrderKey>
				<mun:OrderReference>?</mun:OrderReference>
				<mun:RequestKey>?</mun:RequestKey>
			</tns:queryOrderRequest>")

    xml_hash = hash['tns:queryOrderRequest'];

    xml_hash['mun:MerchantKey'] = request.merchantKey
    xml_hash['mun:OrderKey'] = request.orderKey
    xml_hash['mun:OrderReference'] = request.orderReference
    xml_hash['mun:RequestKey'] = request.requestKey

    response = SendToService(hash, :query_order)

    return response
  end

  def CreateOrder(request)

    parser = Nori.new(:convert_tags_to => lambda { |tag| tag })
    hash = parser.parse('
		         <tns:createOrderRequest>
		            <mun:AmountInCents>?</mun:AmountInCents>
		            <mun:AmountInCentsToConsiderPaid>?</mun:AmountInCentsToConsiderPaid>		            
		            <mun:CurrencyIsoEnum>?</mun:CurrencyIsoEnum>		            
		            <mun:MerchantKey>?</mun:MerchantKey>		            
		            <mun:OrderReference>?</mun:OrderReference>
		            <mun:RequestKey>?</mun:RequestKey>
					<mun:Buyer>
				    </mun:Buyer>
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
    xml_hash['mun:RequestKey'] = request.requestKey

    if request.buyer.nil? == false
      xml_hash['mun:Buyer'] = CreateBuyer(request)
    end

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

    response = SendToService(hash, :create_order)


    return response

  end

  def CreateBuyer(request)

    buyer = {
      'mun:BuyerKey' => request.buyer.buyerKey,
      'mun:BuyerReference' => request.buyer.buyerReference,
      'mun:Email' => request.buyer.email,
      'mun:GenderEnum' => request.buyer.genderEnum,
      'mun:FacebookId' => request.buyer.facebookId,
      'mun:GenderEnum' => request.buyer.genderEnum,
      'mun:HomePhone' => request.buyer.homePhone,
      'mun:IpAddress' => request.buyer.ipAddress,
      'mun:MobilePhone' => request.buyer.mobilePhone,
      'mun:Name' => request.buyer.name,
      'mun:PersonTypeEnum' => request.buyer.personTypeEnum,
      'mun:TaxDocumentNumber' => request.buyer.taxDocumentNumber,
      'mun:TaxDocumentNumberTypeEnum' => request.buyer.taxDocumentTypeEnum,
      'mun:TwitterId' => request.buyer.twitterId,
      'mun:WorkPhone' => request.buyer.workPhone,
      'mun:BuyerAddressCollection' => nil

    }

    if request.buyer.addressCollection.count > 0

    	buyer['mun:BuyerAddressCollection'] = {'mun:BuyerAddress'=>Array.new}

   	    request.buyer.addressCollection.each do |address|

   	    	buyer['mun:BuyerAddressCollection']['mun:BuyerAddress'] << {
   	    		'mun:AddressTypeEnum' => address.addressTypeEnum,
   	    		'mun:City' => address.city,
   	    		'mun:Complement' => address.complement,
   	    		'mun:CountryEnum' => address.countryEnum,
   	    		'mun:District' => address.district,
   	    		'mun:Number' => address.number,
   	    		'mun:State' => address.state,
   	    		'mun:Street' => address.street,
   	    		'mun:ZipCode' => address.zipCode
   	    	}

   	    end
    end

    return buyer

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

  def SendToService(hash, service_method)

    client = Savon.client do
      wsdl "http://simulator.mundipaggone.com/One/MundiPaggService.svc?wsdl"
      namespaces "xmlns:mun" => "http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts"
    end

    response = client.call(service_method, message: hash)

    return response.to_hash
  end

  private :CreateBoletoTransactionRequest, :CreateCreditCardTransaction, :CreateBuyer, :SendToService
end

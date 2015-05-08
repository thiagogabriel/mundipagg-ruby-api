module Mundipagg
  # Class that handles all webservice calls
  class Gateway
    # Sets the soap request log level.
    # Can be: { :debug, :info, :warn, :error or :none }
    # Use :debug only to inspect the Xml sent and received to the service.
    # Default in test environment => :debug
    # Default in production environment => :none
    attr_accessor :log_level

    # @return [Nori] Nori class who handle the conversion of base XML to a hash collection
    # @see https://github.com/savonrb/nori
    attr_reader :parser

    # <i>:test</i> = Simulator enviroment, fake transaction approval;
    # <i>:production</i> = Real transaction, needs real credit card.
    # @return [Symbol] Webservice environment.
    attr_accessor :environment

    # @return [String] URL that points to the simulator WSDL
    @@WEBSERVICE_TEST_URL = 'https://transaction.mundipaggone.com/MundiPaggService.svc?wsdl'

    # @return [String] URL that points to the production WSDL
    @@WEBSERVICE_PRODUCTION_URL = 'https://transaction.mundipaggone.com/MundiPaggService.svc?wsdl'

    # Initialize a class with an environment
    #
    # @param environment [Symbol] Sets the MundiPagg environment will be used by the client.
    def initialize(environment = :test)
      @parser = Nori.new(convert_tags_to: ->(tag) { tag })
      @environment = environment

      if environment == :test
        @log_level = :debug
      else
        @log_level = :error
      end
    end

    # This method makes requests to the webservice method ManageOrder.
    #
    # @param request [CreateOrderRequest] A ManagerOrderRequest instance containing information to capture or void a transaction or order.
    # @return [Hash<Symbol, Object>] A hash collection containing the response data
    def ManageOrder(request)
      hash = @parser.parse('<tns:manageOrderRequest>
                  <mun:ManageCreditCardTransactionCollection>
                  </mun:ManageCreditCardTransactionCollection>
                  <mun:ManageOrderOperationEnum>?</mun:ManageOrderOperationEnum>
                  <mun:MerchantKey>?</mun:MerchantKey>
                  <mun:OrderKey>?</mun:OrderKey>
                  <mun:OrderReference>?</mun:OrderReference>
                  <mun:RequestKey>?</mun:RequestKey>
                </tns:manageOrderRequest>')

      xml_hash = hash['tns:manageOrderRequest']

      xml_hash['mun:ManageCreditCardTransactionCollection'] = { 'mun:ManageCreditCardTransactionRequest' => [] }

      if request.transactionCollection.nil? == false && request.transactionCollection.count > 0

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

      response
    end

    # This method makes requests to the webservice method QueryOrder.
    #
    # @param request [QueryOrderRequest] A QueryOrderRequest instance containing information to request more information about an order or transaction.
    # @return [Hash<Symbol, Object>]
    def QueryOrder(request)
      hash = @parser.parse('<tns:queryOrderRequest>
          <mun:MerchantKey>?</mun:MerchantKey>
          <mun:OrderKey>?</mun:OrderKey>
          <mun:OrderReference>?</mun:OrderReference>
          <mun:RequestKey>?</mun:RequestKey>
        </tns:queryOrderRequest>')

      xml_hash = hash['tns:queryOrderRequest']

      xml_hash['mun:MerchantKey'] = request.merchantKey
      xml_hash['mun:OrderKey'] = request.orderKey
      xml_hash['mun:OrderReference'] = request.orderReference
      xml_hash['mun:RequestKey'] = request.requestKey

      response = SendToService(hash, :query_order)

      response
    end

    # This method makes requests to the webservice method CreateOrder.
    #
    # @param request [CreateOrderRequest] A CreateOrderRequest instance containing information to create a order.
    # @return [Hash<Symbol, Object>] A hash collection containing the response data
    def CreateOrder(request)
      hash = @parser.parse('
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

      xml_hash = hash['tns:createOrderRequest']

      xml_hash['mun:AmountInCents'] = request.amountInCents

      if request.amountInCentsToConsiderPaid.nil?
        xml_hash['mun:AmountInCentsToConsiderPaid'] = request.amountInCents
      else
        xml_hash['mun:AmountInCentsToConsiderPaid'] = request.amountInCentsToConsiderPaid
      end

      xml_hash['mun:CurrencyIsoEnum'] = request.currencyIsoEnum
      xml_hash['mun:MerchantKey'] = request.merchantKey
      xml_hash['mun:OrderReference'] = request.orderReference
      xml_hash['mun:RequestKey'] = request.requestKey

      xml_hash['mun:Buyer'] = CreateBuyer(request) if request.buyer.nil? == false

      if !request.creditCardTransactionCollection.nil? && request.creditCardTransactionCollection.count > 0
        # Create credit card transaction array and assing to the contract hash
        creditCardTransactionCollection = CreateCreditCardTransaction(request)
        xml_hash['mun:CreditCardTransactionCollection'] = creditCardTransactionCollection
      else
        xml_hash['mun:CreditCardTransactionCollection'] = nil
      end

      if request.boletoTransactionCollection.nil? == false && request.boletoTransactionCollection.count > 0
        # Create boleto transaction array and assing to the contract hash
        boletoTransactionCollection = CreateBoletoTransactionRequest(request)
        xml_hash['mun:BoletoTransactionCollection'] = boletoTransactionCollection
      end

      response = SendToService(hash, :create_order)

      response
    end

    # This method create a hash collection with all buyer information.
    # The hash collection is a part of the data send to the webservice.
    #
    # @param request [CreateOrderRequest]
    # @return [Hash<Symbol, Object>] Hash collection with buyer information.
    # @!visibility private
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

        buyer['mun:BuyerAddressCollection'] = { 'mun:BuyerAddress' => [] }

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

      buyer
    end

    # This method create a hash collection with all boleto transactions information.
    # The hash collection is a part of the data send to the webservice.
    #
    # @param boletoRequest [Array<BoletoTransaction>] CreateOrderRequest instance
    # @return [Hash<Symbol, Object>] Hash collection with one or more boleto transactions.
    # @!visibility private
    def CreateBoletoTransactionRequest(boletoRequest)
      transactionCollection = { 'mun:BoletoTransaction' => [] }

      boletoRequest.boletoTransactionCollection.each do |boleto|
        transactionCollection['mun:BoletoTransaction'] << {
          'mun:AmountInCents' => boleto.amountInCents,
          'mun:BankNumber' => boleto.bankNumber,
          'mun:DaysToAddInBoletoExpirationDate' => boleto.daysToAddInBoletoExpirationDate,
          'mun:Instructions' => boleto.instructions,
          'mun:NossoNumero' => boleto.nossoNumero,
          'mun:TransactionReference' => boleto.transactionReference

        }
      end

      transactionCollection
    end

    # This method create a hash collection with all credit card transactions information.
    # The hash collection is a part of the data send to the webservice.
    #
    # @param creditCardRequest [Array<CreditCardTransaction>] CreateOrderRequest instance
    # @return [Hash<Symbol, Object>] Hash collection with one or more credit card transactions.
    # @!visibility private
    def CreateCreditCardTransaction(creditCardRequest)
      transactionCollection = { 'mun:CreditCardTransaction' => [] }

      creditCardRequest.creditCardTransactionCollection.each do |transaction|
        if environment == :test
          transaction.paymentMethodCode = 1 # Simulator payment code
        end

        transaction_hash = if transaction.instantBuyKey
                             {
                               'mun:AmountInCents' => transaction.amountInCents,
                               'mun:CreditCardBrandEnum' => transaction.creditCardBrandEnum.to_s,
                               'mun:InstantBuyKey' => transaction.instantBuyKey,
                               'mun:CreditCardOperationEnum' => transaction.creditCardOperationEnum.to_s,
                               'mun:InstallmentCount' => transaction.installmentCount,
                               'mun:PaymentMethodCode' => transaction.paymentMethodCode,
                               'mun:TransactionReference' => transaction.transactionReference
                             }
                           else
                             {
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

        if transaction.recurrency.nil? == false
          transaction_hash['mun:Recurrency'] = {
            'mun:DateToStartBilling' => transaction.recurrency.dateToStartBilling,
            'mun:FrequencyEnum' => transaction.recurrency.frequencyEnum,
            'mun:Interval' => transaction.recurrency.interval,
            'mun:OneDollarAuth' => transaction.recurrency.oneDollarAuth,
            'mun:Recurrences' => transaction.recurrency.recurrences
          }
        end

        transactionCollection['mun:CreditCardTransaction'] << transaction_hash
      end

      transactionCollection
    end

    # This method send the hash collectin created in this client and send it to the webservice.
    #
    # == Parameters:
    # @param hash [Hash<Symbol, Object] Hash collection generated by Nori using the base SOAP XML.
    # @param service_method [Symbol] A Symbol declaring the method that will be called. Can be <i>:create_order</i>, <i>:manage_order<i/> or <i>:query_order</i>.
    # @return [Hash<Symbol, Object>] A hash collection with the service method response.
    # @!visibility private
    def SendToService(hash, service_method)
      url = nil

      if @environment == :production
        url = @@WEBSERVICE_PRODUCTION_URL
      else
        url = @@WEBSERVICE_TEST_URL
      end
      savon_levels = { none: -1, debug: 0, info: 1, warn: 2, error: 3 }

      @log_level = :none unless savon_levels.include? @log_level

      level = :debug
      enable_log = true
      filters = [:CreditCardNumber,
                 :SecurityCode,
                 :MerchantKey]

      if @log_level == :none
        level = :error
        enable_log = false
      end

      client = Savon.client do
        wsdl url
        log enable_log
        log_level level
        filters filters
        namespaces 'xmlns:mun' => 'http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts'
      end

      response = client.call(service_method) do
        message hash
      end

      response.to_hash
    end

    private :CreateBoletoTransactionRequest, :CreateCreditCardTransaction, :CreateBuyer, :SendToService, :parser
  end
end

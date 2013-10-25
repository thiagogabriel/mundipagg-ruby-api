# encoding: UTF-8

Before do
	FakeWeb.clean_registry

	FakeWeb.register_uri(:get, "https://transaction.mundipaggone.com/MundiPaggService.svc", 
		:body => ' <?xml version="1.0" encoding="UTF-8"?><env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tns="http://tempuri.org/" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mun="http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts"><env:Body><tns:CreateOrder><tns:createOrderRequest><mun:AmountInCents>10000</mun:AmountInCents><mun:AmountInCentsToConsiderPaid>10000</mun:AmountInCentsToConsiderPaid><mun:CurrencyIsoEnum>BRL</mun:CurrencyIsoEnum><mun:MerchantKey>8a2dd57f-1ed9-4153-b4ce-69683efadad5</mun:MerchantKey><mun:OrderReference xsi:nil="true"/><mun:RequestKey>00000000-0000-0000-0000-000000000000</mun:RequestKey><mun:Buyer xsi:nil="true"/><mun:CreditCardTransactionCollection><mun:CreditCardTransaction><mun:AmountInCents>10000</mun:AmountInCents><mun:CreditCardBrandEnum>Visa</mun:CreditCardBrandEnum><mun:CreditCardNumber>4111111111111111</mun:CreditCardNumber><mun:CreditCardOperationEnum>AuthOnly</mun:CreditCardOperationEnum><mun:ExpMonth>5</mun:ExpMonth><mun:ExpYear>2020</mun:ExpYear><mun:HolderName>Bruce Wayne</mun:HolderName><mun:InstallmentCount>1</mun:InstallmentCount><mun:PaymentMethodCode>1</mun:PaymentMethodCode><mun:SecurityCode>123</mun:SecurityCode><mun:TransactionReference>Custom Transaction Identifier</mun:TransactionReference></mun:CreditCardTransaction></mun:CreditCardTransactionCollection><mun:BoletoTransactionCollection xsi:nil="true"/></tns:createOrderRequest></tns:CreateOrder></env:Body></env:Envelope>',
		:content_type=>'text/xml;charset=UTF-8')
	
	FakeWeb.register_uri(:post, "https://transaction.mundipaggone.com/MundiPaggService.svc", 
		:body => '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><CreateOrderResponse xmlns="http://tempuri.org/"><CreateOrderResult xmlns:a="http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><a:BuyerKey>00000000-0000-0000-0000-000000000000</a:BuyerKey><a:MerchantKey>8a2dd57f-1ed9-4153-b4ce-69683efadad5</a:MerchantKey><a:MundiPaggTimeInMilliseconds>785</a:MundiPaggTimeInMilliseconds><a:OrderKey>dba621d5-2b7e-49ac-b6c4-d1cde3bd8768</a:OrderKey><a:OrderReference>44f38704</a:OrderReference><a:OrderStatusEnum>Opened</a:OrderStatusEnum><a:RequestKey>e88335ce-e0a3-43d1-9bae-3e6781f0a5ba</a:RequestKey><a:Success>true</a:Success><a:Version>1.0</a:Version><a:CreditCardTransactionResultCollection><a:CreditCardTransactionResult><a:AcquirerMessage>Transação de simulação autorizada com sucesso</a:AcquirerMessage><a:AcquirerReturnCode>0</a:AcquirerReturnCode><a:AmountInCents>10000</a:AmountInCents><a:AuthorizationCode>740990</a:AuthorizationCode><a:AuthorizedAmountInCents>10000</a:AuthorizedAmountInCents><a:CapturedAmountInCents i:nil="true"/><a:CreditCardNumber>411111****1111</a:CreditCardNumber><a:CreditCardOperationEnum>AuthOnly</a:CreditCardOperationEnum><a:CreditCardTransactionStatusEnum>AuthorizedPendingCapture</a:CreditCardTransactionStatusEnum><a:CustomStatus i:nil="true"/><a:DueDate i:nil="true"/><a:ExternalTimeInMilliseconds>53</a:ExternalTimeInMilliseconds><a:InstantBuyKey>d22f0e16-2d3a-46aa-b138-c79ec2a0106e</a:InstantBuyKey><a:RefundedAmountInCents i:nil="true"/><a:Success>true</a:Success><a:TransactionIdentifier>744564</a:TransactionIdentifier><a:TransactionKey>76323727-fcce-4c16-8af2-ba7a5fa5f647</a:TransactionKey><a:TransactionReference>Custom Transaction Identifier</a:TransactionReference><a:UniqueSequentialNumber>408808</a:UniqueSequentialNumber><a:VoidedAmountInCents i:nil="true"/><a:OriginalAcquirerReturnCollection i:nil="true"/></a:CreditCardTransactionResult></a:CreditCardTransactionResultCollection><a:BoletoTransactionResultCollection/><a:MundiPaggSuggestion i:nil="true"/><a:ErrorReport i:nil="true"/></CreateOrderResult></CreateOrderResponse></s:Body></s:Envelope>',
		:content_type=>'text/xml;charset=UTF-8')


	@client = Mundipagg::Gateway.new :test
	@client.log_level = :error

	@order = Mundipagg::CreateOrderRequest.new
	@manage_order = Mundipagg::ManageOrderRequest.new

	@manage_order.merchantKey = TestConfiguration::Merchant::MerchantKey
	@order.merchantKey =  TestConfiguration::Merchant::MerchantKey
	
	@transaction = Mundipagg::CreditCardTransaction.new
	@order.creditCardTransactionCollection << @transaction

	$world = self	
end

Given(/^I have pre authorized a credit card transaction of (\w+) (\d+)\.(\d+)$/) do |currency, amount, cents|
	
	amount_decimal = TestHelper.JoinAndConvertAmountAndCents(amount, cents)
	
	@order.currencyIsoEnum = currency
	@order.amountInCents = (amount_decimal * 100).to_i
	@order.amountInCentsToConsiderPaid = (amount_decimal * 100).to_i

	@transaction.amountInCents = @order.amountInCents; 
	@transaction.creditCardBrandEnum = Mundipagg::CreditCardTransaction.BrandEnum[:Visa]
	@transaction.creditCardOperationEnum = Mundipagg::CreditCardTransaction.OperationEnum[:AuthOnly] #Pre-authorization
	@transaction.creditCardNumber = '4111111111111111'
	@transaction.holderName = 'Bruce Wayne'
	@transaction.installmentCount = 1
	@transaction.paymentMethodCode = 1
	@transaction.securityCode = 123
	@transaction.transactionReference = 'Custom Transaction Identifier'
	@transaction.expirationMonth = 5
	@transaction.expirationYear = 2020

	response_hash = @client.CreateOrder(@order)
	@response = response_hash[:create_order_response][:create_order_result]
	@credit_card_result = @response[:credit_card_transaction_result_collection][:credit_card_transaction_result]

	@response[:success].should == true
	@response[:order_status_enum].should == 'Opened'
	@credit_card_result[:amount_in_cents].to_i.should == @order.amountInCents
	@credit_card_result[:credit_card_operation_enum].should == 'AuthOnly'
	@credit_card_result[:credit_card_transaction_status_enum].should == 'AuthorizedPendingCapture'
end

Given(/^I captured the transaction$/) do

	FakeWeb.clean_registry

	FakeWeb.register_uri(:get, "https://transaction.mundipaggone.com/MundiPaggService.svc", 
		:body => '<?xml version="1.0" encoding="UTF-8"?><env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tns="http://tempuri.org/" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mun="http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts"><env:Body><tns:ManageOrder><tns:manageOrderRequest><mun:ManageCreditCardTransactionCollection><mun:ManageCreditCardTransactionRequest><mun:AmountInCents>10000</mun:AmountInCents><mun:TransactionKey>76323727-fcce-4c16-8af2-ba7a5fa5f647</mun:TransactionKey><mun:TransactionReference xsi:nil="true"/></mun:ManageCreditCardTransactionRequest></mun:ManageCreditCardTransactionCollection><mun:ManageOrderOperationEnum>Capture</mun:ManageOrderOperationEnum><mun:MerchantKey>8a2dd57f-1ed9-4153-b4ce-69683efadad5</mun:MerchantKey><mun:OrderKey>dba621d5-2b7e-49ac-b6c4-d1cde3bd8768</mun:OrderKey><mun:OrderReference xsi:nil="true"/><mun:RequestKey>00000000-0000-0000-0000-000000000000</mun:RequestKey></tns:manageOrderRequest></tns:ManageOrder></env:Body></env:Envelope>',
		:content_type=>'text/xml;charset=UTF-8')
	
	FakeWeb.register_uri(:post, "https://transaction.mundipaggone.com/MundiPaggService.svc", 
		:body => '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><ManageOrderResponse xmlns="http://tempuri.org/"><ManageOrderResult xmlns:a="http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><a:ManageOrderOperationEnum>Capture</a:ManageOrderOperationEnum><a:MundiPaggTimeInMilliseconds>215</a:MundiPaggTimeInMilliseconds><a:OrderKey>dba621d5-2b7e-49ac-b6c4-d1cde3bd8768</a:OrderKey><a:OrderReference i:nil="true"/><a:OrderStatusEnum>Paid</a:OrderStatusEnum><a:RequestKey>41e8d0f3-3372-411b-b49f-c237db53a67a</a:RequestKey><a:Success>true</a:Success><a:Version>1.0</a:Version><a:CreditCardTransactionResultCollection><a:CreditCardTransactionResult><a:AcquirerMessage>Transação de simulação capturada com sucesso</a:AcquirerMessage><a:AcquirerReturnCode>0</a:AcquirerReturnCode><a:AmountInCents>10000</a:AmountInCents><a:AuthorizationCode>740990</a:AuthorizationCode><a:AuthorizedAmountInCents>10000</a:AuthorizedAmountInCents><a:CapturedAmountInCents>10000</a:CapturedAmountInCents><a:CreditCardNumber>411111****1111</a:CreditCardNumber><a:CreditCardOperationEnum>AuthOnly</a:CreditCardOperationEnum><a:CreditCardTransactionStatusEnum>Captured</a:CreditCardTransactionStatusEnum><a:CustomStatus i:nil="true"/><a:DueDate i:nil="true"/><a:ExternalTimeInMilliseconds>95</a:ExternalTimeInMilliseconds><a:InstantBuyKey>d22f0e16-2d3a-46aa-b138-c79ec2a0106e</a:InstantBuyKey><a:RefundedAmountInCents i:nil="true"/><a:Success>true</a:Success><a:TransactionIdentifier>980189</a:TransactionIdentifier><a:TransactionKey>76323727-fcce-4c16-8af2-ba7a5fa5f647</a:TransactionKey><a:TransactionReference>Custom Transaction Identifier</a:TransactionReference><a:UniqueSequentialNumber>140934</a:UniqueSequentialNumber><a:VoidedAmountInCents i:nil="true"/><a:OriginalAcquirerReturnCollection i:nil="true"/></a:CreditCardTransactionResult></a:CreditCardTransactionResultCollection><a:BoletoTransactionResultCollection/><a:MundiPaggSuggestion i:nil="true"/><a:ErrorReport i:nil="true"/></ManageOrderResult></ManageOrderResponse></s:Body></s:Envelope>',
		:content_type=>'text/xml;charset=UTF-8')


	@manage_order.orderKey = @response[:order_key]

	@manage_order.manageOrderOperationEnum = Mundipagg::ManageOrderRequest.OperationEnum[:Capture]

	@manage_order.transactionCollection << Mundipagg::ManageTransactionRequest.new
	@manage_order.transactionCollection[0].amountInCents = @credit_card_result[:amount_in_cents]
	@manage_order.transactionCollection[0].transactionKey = @credit_card_result[:transaction_key]

	response_hash = @client.ManageOrder(@manage_order)
	@response_manage = response_hash[:manage_order_response][:manage_order_result]

	@response_manage[:manage_order_operation_enum].should == 'Capture'
	@response_manage[:order_status_enum].should == 'Paid'
	@response_manage[:success].should == true
	@response_manage[:credit_card_transaction_result_collection].should_not == nil
	@response_manage[:credit_card_transaction_result_collection][:credit_card_transaction_result].should_not == nil

	transaction_result_hash = @response_manage[:credit_card_transaction_result_collection][:credit_card_transaction_result]

	transaction_result_hash[:amount_in_cents].to_i.should == @order.amountInCents
	transaction_result_hash[:success].should == true


end

Then(/^I will receive a POST notification telling my transaction has been (\w+)$/) do |return_status|
	xml = TestHelper.CreateFakePostNotification(@response, @response_manage)

	@notification_hash = Mundipagg::PostNotification.ParseNotification(xml)

	@notification_hash.should_not == nil
	@notification_hash.count.should > 0
	@notification_hash[:status_notification][:credit_card_transaction][:credit_card_transaction_status].downcase.should == return_status.downcase
end

Then(/^the amount captured should be (\w+) (\d+)\.(\d+)$/) do |currency, amount, cents|
	amount_decimal = TestHelper.JoinAndConvertAmountAndCents(amount, cents)
	@notification_hash[:status_notification][:credit_card_transaction][:captured_amount_in_cents].to_i.should == (amount_decimal.to_i) *100
end

After do |s|
	FakeWeb.clean_registry
end

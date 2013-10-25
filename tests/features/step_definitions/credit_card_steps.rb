begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end
$:.unshift(File.dirname(__FILE__) + '/../../../lib') 
require 'bigdecimal'
require 'mundipagg'

#Scenario 1: 
Before do 
	FakeWeb.clean_registry

	@client = Mundipagg::Gateway.new :test
	@order = Mundipagg::CreateOrderRequest.new
	@order.merchantKey = TestConfiguration::Merchant::MerchantKey
	@transaction = Mundipagg::CreditCardTransaction.new
	@order.creditCardTransactionCollection << @transaction
	@response = Hash.new

	FakeWeb.register_uri(:get, "https://transaction.mundipaggone.com/MundiPaggService.svc", 
		:body => '<?xml version="1.0" encoding="UTF-8"?><env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tns="http://tempuri.org/" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mun="http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts"><env:Body><tns:CreateOrder><tns:createOrderRequest><mun:AmountInCents>10029</mun:AmountInCents><mun:AmountInCentsToConsiderPaid>10029</mun:AmountInCentsToConsiderPaid><mun:CurrencyIsoEnum>BRL</mun:CurrencyIsoEnum><mun:MerchantKey>8a2dd57f-1ed9-4153-b4ce-69683efadad5</mun:MerchantKey><mun:OrderReference xsi:nil="true"/><mun:RequestKey>00000000-0000-0000-0000-000000000000</mun:RequestKey><mun:Buyer xsi:nil="true"/><mun:CreditCardTransactionCollection><mun:CreditCardTransaction><mun:AmountInCents>10029</mun:AmountInCents><mun:CreditCardBrandEnum>Visa</mun:CreditCardBrandEnum><mun:CreditCardNumber>41111111111111111</mun:CreditCardNumber><mun:CreditCardOperationEnum>AuthAndCapture</mun:CreditCardOperationEnum><mun:ExpMonth>5</mun:ExpMonth><mun:ExpYear>2018</mun:ExpYear><mun:HolderName>Ruby Unit Test</mun:HolderName><mun:InstallmentCount>1</mun:InstallmentCount><mun:PaymentMethodCode>1</mun:PaymentMethodCode><mun:SecurityCode>123</mun:SecurityCode><mun:TransactionReference xsi:nil="true"/></mun:CreditCardTransaction></mun:CreditCardTransactionCollection><mun:BoletoTransactionCollection xsi:nil="true"/></tns:createOrderRequest></tns:CreateOrder></env:Body></env:Envelope>',
		:content_type=>'text/xml;charset=UTF-8')
	
	FakeWeb.register_uri(:post, "https://transaction.mundipaggone.com/MundiPaggService.svc", 
		:body => '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><CreateOrderResponse xmlns="http://tempuri.org/"><CreateOrderResult xmlns:a="http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><a:BuyerKey>00000000-0000-0000-0000-000000000000</a:BuyerKey><a:MerchantKey>8a2dd57f-1ed9-4153-b4ce-69683efadad5</a:MerchantKey><a:MundiPaggTimeInMilliseconds>885</a:MundiPaggTimeInMilliseconds><a:OrderKey>5f496382-1506-44d9-a066-7421d5ec42b4</a:OrderKey><a:OrderReference>398cdcd7</a:OrderReference><a:OrderStatusEnum>Paid</a:OrderStatusEnum><a:RequestKey>43ded75a-9e73-4eca-8113-90ffab2e5fdf</a:RequestKey><a:Success>true</a:Success><a:Version>1.0</a:Version><a:CreditCardTransactionResultCollection><a:CreditCardTransactionResult><a:AcquirerMessage>Transação de simulação autorizada com sucesso</a:AcquirerMessage><a:AcquirerReturnCode>0</a:AcquirerReturnCode><a:AmountInCents>10029</a:AmountInCents><a:AuthorizationCode>229077</a:AuthorizationCode><a:AuthorizedAmountInCents>10029</a:AuthorizedAmountInCents><a:CapturedAmountInCents>10029</a:CapturedAmountInCents><a:CreditCardNumber>411111****1111</a:CreditCardNumber><a:CreditCardOperationEnum>AuthAndCapture</a:CreditCardOperationEnum><a:CreditCardTransactionStatusEnum>Captured</a:CreditCardTransactionStatusEnum><a:CustomStatus i:nil="true"/><a:DueDate i:nil="true"/><a:ExternalTimeInMilliseconds>57</a:ExternalTimeInMilliseconds><a:InstantBuyKey>b9b9e82f-2214-459e-8d5f-b8b733661c50</a:InstantBuyKey><a:RefundedAmountInCents i:nil="true"/><a:Success>true</a:Success><a:TransactionIdentifier>387498</a:TransactionIdentifier><a:TransactionKey>6e75284e-6059-4bfc-9299-1f55197c06cd</a:TransactionKey><a:TransactionReference>a9e45b14</a:TransactionReference><a:UniqueSequentialNumber>142807</a:UniqueSequentialNumber><a:VoidedAmountInCents i:nil="true"/><a:OriginalAcquirerReturnCollection i:nil="true"/></a:CreditCardTransactionResult></a:CreditCardTransactionResultCollection><a:BoletoTransactionResultCollection/><a:MundiPaggSuggestion i:nil="true"/><a:ErrorReport i:nil="true"/></CreateOrderResult></CreateOrderResponse></s:Body></s:Envelope>',
		:content_type=>'text/xml;charset=UTF-8')

end


Given(/^I have purchase three products with a total cost of (\w+) (\d+)$/) do |currency,amount|
	amount = BigDecimal.new(amount.gsub(',', '.'))
	@order.amountInCents = (amount * 100).to_i
	@order.amountInCentsToConsiderPaid = (amount * 100).to_i
	@order.currencyIsoEnum = 'BRL'
end

Given(/^I will pay using a (\w+) credit card in (\d+) installments$/) do |brand,installments|
	@transaction.creditCardBrandEnum = brand
	@transaction.installmentCount = installments
	@transaction.paymentMethodCode = 1
	@transaction.amountInCents = @order.amountInCents
	@transaction.holderName = 'Ruby Unit Test'
	@transaction.creditCardNumber = '41111111111111111'
	@transaction.securityCode = '123'
	@transaction.expirationMonth = 5
	@transaction.expirationYear = 2018
	@transaction.creditCardOperationEnum = Mundipagg::CreditCardTransaction.OperationEnum[:AuthAndCapture]
end

Given(/^I will send to Mundipagg$/) do
	@response = @client.CreateOrder(@order)
end

Then(/^the order amount in cents should be (\d+)$/) do |amountInCents|
	transaction = @response[:create_order_response][:create_order_result][:credit_card_transaction_result_collection][:credit_card_transaction_result]
	transaction[:amount_in_cents].to_s.should == amountInCents
end

Then(/^the transaction status should be (\w+)$/) do |status| 
	transaction = @response[:create_order_response][:create_order_result][:credit_card_transaction_result_collection][:credit_card_transaction_result]
	transaction[:credit_card_transaction_status_enum].to_s.downcase.should == status.downcase
end


#Scenario 2:

Given(/^I have purchase three products with a total cost of (\w+) (\d+),(\d+)$/) do |currency, amount, cents|
	amount = amount+'.'+cents
	amount = BigDecimal.new(amount.gsub(',', '.'))
	@order.amountInCents = (amount * 100).to_i
	@order.amountInCentsToConsiderPaid = (amount * 100).to_i
	@order.currencyIsoEnum = currency

end

Given(/^I will pay using a (\w+) credit card without installment$/) do |brand|
	@transaction.creditCardBrandEnum = brand
	@transaction.installmentCount = 1
	@transaction.paymentMethodCode = 1
	@transaction.amountInCents = @order.amountInCents
	@transaction.holderName = 'Ruby Unit Test'
	@transaction.creditCardNumber = '41111111111111111'
	@transaction.securityCode = '123'
	@transaction.expirationMonth = 5
	@transaction.expirationYear = 2018
	@transaction.creditCardOperationEnum = Mundipagg::CreditCardTransaction.OperationEnum[:AuthAndCapture]

end

After do |s|
	FakeWeb.clean_registry
end

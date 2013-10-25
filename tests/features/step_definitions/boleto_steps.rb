# encoding: UTF-8

Before do 
	@client = Mundipagg::Gateway.new :test
	@order = Mundipagg::CreateOrderRequest.new
	@boleto = Mundipagg::BoletoTransaction.new
	@response = Hash.new
	@order.merchantKey = TestConfiguration::Merchant::MerchantKey

	FakeWeb.register_uri(:get, "https://transaction.mundipaggone.com/MundiPaggService.svc", 
		:body => '<?xml version="1.0" encoding="UTF-8"?><env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tns="http://tempuri.org/" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mun="http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts"><env:Body><tns:CreateOrder><tns:createOrderRequest><mun:AmountInCents>5000</mun:AmountInCents><mun:AmountInCentsToConsiderPaid>5000</mun:AmountInCentsToConsiderPaid><mun:CurrencyIsoEnum>BRL</mun:CurrencyIsoEnum><mun:MerchantKey>8a2dd57f-1ed9-4153-b4ce-69683efadad5</mun:MerchantKey><mun:OrderReference xsi:nil="true"/><mun:RequestKey>00000000-0000-0000-0000-000000000000</mun:RequestKey><mun:Buyer xsi:nil="true"/><mun:CreditCardTransactionCollection xsi:nil="true"/><mun:BoletoTransactionCollection><mun:BoletoTransaction><mun:AmountInCents>5000</mun:AmountInCents><mun:BankNumber>1</mun:BankNumber><mun:DaysToAddInBoletoExpirationDate>15</mun:DaysToAddInBoletoExpirationDate><mun:Instructions>Não receber após o vencimento</mun:Instructions><mun:NossoNumero>989790</mun:NossoNumero><mun:TransactionReference>327898903</mun:TransactionReference></mun:BoletoTransaction></mun:BoletoTransactionCollection></tns:createOrderRequest></tns:CreateOrder></env:Body></env:Envelope>',
		:content_type=>'text/xml;charset=UTF-8')
	
	FakeWeb.register_uri(:post, "https://transaction.mundipaggone.com/MundiPaggService.svc", 
		:body => '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><CreateOrderResponse xmlns="http://tempuri.org/"><CreateOrderResult xmlns:a="http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><a:BuyerKey>00000000-0000-0000-0000-000000000000</a:BuyerKey><a:MerchantKey>8a2dd57f-1ed9-4153-b4ce-69683efadad5</a:MerchantKey><a:MundiPaggTimeInMilliseconds>718</a:MundiPaggTimeInMilliseconds><a:OrderKey>53ed863d-37c2-465e-a409-b41d1c8a3288</a:OrderKey><a:OrderReference>78d7871c</a:OrderReference><a:OrderStatusEnum>Opened</a:OrderStatusEnum><a:RequestKey>6b10aa93-40a5-413e-90d8-addc7cf1a63f</a:RequestKey><a:Success>true</a:Success><a:Version>1.0</a:Version><a:CreditCardTransactionResultCollection/><a:BoletoTransactionResultCollection><a:BoletoTransactionResult><a:AmountInCents>5000</a:AmountInCents><a:Barcode>03399.58084 99500.000098 89790.901022 8 58560000005000</a:Barcode><a:BoletoTransactionStatusEnum>Generated</a:BoletoTransactionStatusEnum><a:BoletoUrl>https://transaction.mundipaggone.com/Boleto/ViewBoleto.aspx?36ae1c28-acb8-4c11-8628-1456a1a4098d</a:BoletoUrl><a:CustomStatus i:nil="true"/><a:NossoNumero>000000989790</a:NossoNumero><a:Success>true</a:Success><a:TransactionKey>36ae1c28-acb8-4c11-8628-1456a1a4098d</a:TransactionKey><a:TransactionReference>327898903</a:TransactionReference></a:BoletoTransactionResult></a:BoletoTransactionResultCollection><a:MundiPaggSuggestion i:nil="true"/><a:ErrorReport i:nil="true"/></CreateOrderResult></CreateOrderResponse></s:Body></s:Envelope>',
		:content_type=>'text/xml;charset=UTF-8')



end


Given(/^I have purchase two products with a total cost of (\w+) (\d+)\.(\d+)$/) do |currency,amount,cents|
	amount = amount+'.'+cents
	amount = BigDecimal.new(amount.gsub(',', '.'))
	@order.amountInCents = (amount * 100).to_i
	@order.amountInCentsToConsiderPaid = (amount * 100).to_i
	@order.currencyIsoEnum = 'BRL'
end

Given(/^I will pay using (\w+) with (\d+) days to expire$/) do |type,daysToExpire|
  if type.downcase == 'boleto'
  	
  	@boleto.amountInCents = @order.amountInCents
  	@boleto.bankNumber = 1
  	@boleto.nossoNumero = 989790
  	@boleto.transactionReference = rand(389546232)
  	@boleto.daysToAddInBoletoExpirationDate = daysToExpire
  	@boleto.instructions = 'Não receber após o vencimento'

  	@order.boletoTransactionCollection << @boleto
  	@order.creditCardTransactionCollection = nil

  end
end

Given(/^I send to Mundipagg$/) do
	@response = @client.CreateOrder(@order)
end


Then(/^The order amount in cents should be (\d+)$/) do |amountInCents|
	transaction = @response[:create_order_response][:create_order_result][:boleto_transaction_result_collection][:boleto_transaction_result]
	transaction[:amount_in_cents].to_s.should == amountInCents
end

Then(/^The boleto status should be (\w+)$/) do |status|
	transaction = @response[:create_order_response][:create_order_result][:boleto_transaction_result_collection][:boleto_transaction_result]
	transaction[:boleto_transaction_status_enum].to_s == status
end

After do
	FakeWeb.clean_registry
end

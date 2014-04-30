# encoding: UTF-8

Before do 
	@client = Mundipagg::Gateway.new :test
	@client.log_level = :debug
	@order = Mundipagg::CreateOrderRequest.new
	@boleto = Mundipagg::BoletoTransaction.new
	@response = Hash.new
	@order.merchantKey = TestConfiguration::Merchant::MerchantKey
	$world = self
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

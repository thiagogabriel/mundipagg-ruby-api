
#Scenario 1: 
Before do 

	@client = Mundipagg::Gateway.new :test
	@client.log_level = :none
	@order = Mundipagg::CreateOrderRequest.new
	@order.merchantKey = TestConfiguration::Merchant::MerchantKey
	@transaction = Mundipagg::CreditCardTransaction.new
	@order.creditCardTransactionCollection << @transaction
	@response = Hash.new

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
  old_stdout = $stdout
  @stdout = StringIO.new
  $stdout = @stdout
  @client.log_level = :debug
  begin
    @response = @client.CreateOrder(@order)
  ensure
    $stdout = old_stdout
  end
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

#Scenario 3:

Then(/^the log file doesn't contain sensible information$/) do
  @stdout.string.should_not include(@transaction.creditCardNumber)
  @stdout.string.should_not include(@transaction.securityCode)
  @stdout.string.should_not include(@order.merchantKey)
end

#Scenario 4:
When(/^I pay another order with the instant buy key$/) do
  @order = Mundipagg::CreateOrderRequest.new
  @order.merchantKey = TestConfiguration::Merchant::MerchantKey
  amount = 100
  @transaction = Mundipagg::CreditCardTransaction.new
  @order.creditCardTransactionCollection << @transaction

  @order.amountInCents = (amount * 100).to_i
  @order.amountInCentsToConsiderPaid = (amount * 100).to_i
  @order.currencyIsoEnum = 'BRL'

  @transaction.creditCardBrandEnum = 'Visa'
  @transaction.instantBuyKey = @response[:create_order_response][:create_order_result][:credit_card_transaction_result_collection][:credit_card_transaction_result][:instant_buy_key]
  @transaction.installmentCount = 1
  @transaction.paymentMethodCode = 1
  @transaction.amountInCents = @order.amountInCents
  @transaction.creditCardOperationEnum = Mundipagg::CreditCardTransaction.OperationEnum[:AuthAndCapture]

  old_stdout = $stdout
  @stdout = StringIO.new
  $stdout = @stdout
  @client.log_level = :debug
  begin
    @response = @client.CreateOrder(@order)
  ensure
    $stdout = old_stdout
  end
end

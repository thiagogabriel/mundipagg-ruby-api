# encoding: UTF-8
Before do

	@client = Mundipagg::Gateway.new :production
	@client.log_level = :none

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
	pp @notification_hash, :indent => true

	@notification_hash.should_not == nil
	@notification_hash.count.should > 0
	@notification_hash[:status_notification][:credit_card_transaction][:credit_card_transaction_status].downcase.should == return_status.downcase
end

Then(/^the amount captured should be (\w+) (\d+)\.(\d+)$/) do |currency, amount, cents|
	amount_decimal = TestHelper.JoinAndConvertAmountAndCents(amount, cents)
	@notification_hash[:status_notification][:credit_card_transaction][:captured_amount_in_cents].to_i.should == (amount_decimal.to_i) *100
end

MundiPagg Ruby Client Library
====================

[![Build Status](https://travis-ci.org/mundipagg/ruby-integration-api.png?branch=master)](https://travis-ci.org/mundipagg/ruby-integration-api)[![Gem Version](https://badge.fury.io/rb/mundipagg.png)](http://badge.fury.io/rb/mundipagg)

Ruby API for integration with MundiPagg payment web services.

## Dependencies 
* [Savon 2.3.0](http://savonrb.com/version2/)
	* [Nori 2.3.0](https://github.com/savonrb/nori)

Unit tests made with [Cucumber](https://github.com/cucumber/cucumber) and [RSpec](https://github.com/rspec/rspec)

## Documentation 
* [Wiki](https://github.com/mundipagg/mundipagg-ruby-api/wiki)
* [RubyDoc](http://rubydoc.info/github/mundipagg/mundipagg-ruby-api/)


## Usage
Below a simple exemple of an order with one credit card transaction.

```sh
$ gem install mundipagg
```

```ruby
require 'mundipagg'

#Create the client instance
client = Mundipagg::Gateway.new :production

#Create the order
order = Mundipagg::CreateOrderRequest.new

#Fill order information
order.amountInCents = 1000 # R$ 10,00
order.amountInCentsToConsiderPaid = 1000
order.merchantKey = '00000000-0000-0000-0000-000000000000'
order.orderReference = 'Custom Order 42'


#Credit card transaction information
credit = Mundipagg::CreditCardTransaction.new

credit.amountInCents = 1000; # R$ 10,00
credit.creditCardBrandEnum = Mundipagg::CreditCardTransaction.BrandEnum[:Visa]
credit.creditCardOperationEnum = Mundipagg::CreditCardTransaction.OperationEnum[:AuthAndCapture]
credit.creditCardNumber = '4111111111111111'
credit.holderName = 'Anthony Edward Stark'
credit.installmentCount = 1
credit.paymentMethodCode = 1 #Simulator
credit.securityCode = 123
credit.transactionReference = 'Custom Transaction Identifier'
credit.expirationMonth = 5
credit.expirationYear = 2020

#Add transaction to order
order.creditCardTransactionCollection << credit

response = client.CreateOrder(order)
```

The response variable will contain a Hash like the one below.

```ruby
{:create_order_response=>
  {:create_order_result=>
    {:buyer_key=>"00000000-0000-0000-0000-000000000000",
     :merchant_key=>"00000000-0000-0000-0000-000000000000",
     :mundi_pagg_time_in_milliseconds=>"358",
     :order_key=>"00000000-0000-0000-0000-000000000000",
     :order_reference=>"Custom Order 42",
     :order_status_enum=>"Paid",
     :request_key=>"00000000-0000-0000-0000-000000000000",
     :success=>true,
     :version=>"1.0",
     :credit_card_transaction_result_collection=>
      {:credit_card_transaction_result=>
        {:acquirer_message=>"Transação de simulação autorizada com sucesso",
         :acquirer_return_code=>"0",
         :amount_in_cents=>"1000",
         :authorization_code=>"221672",
         :authorized_amount_in_cents=>"1000",
         :captured_amount_in_cents=>"1000",
         :credit_card_number=>"411111****1111",
         :credit_card_operation_enum=>"AuthAndCapture",
         :credit_card_transaction_status_enum=>"Captured",
         :custom_status=>nil,
         :due_date=>nil,
         :external_time_in_milliseconds=>"76",
         :instant_buy_key=>"00000000-0000-0000-0000-000000000000",
         :refunded_amount_in_cents=>nil,
         :success=>true,
         :transaction_identifier=>"774353",
         :transaction_key=>"00000000-0000-0000-0000-000000000000",
         :transaction_reference=>"Custom Transaction Identifier",
         :unique_sequential_number=>"383884",
         :voided_amount_in_cents=>nil,
         :original_acquirer_return_collection=>nil}},
     :boleto_transaction_result_collection=>nil,
     :mundi_pagg_suggestion=>nil,
     :error_report=>nil,
     :"@xmlns:a"=>"http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts",
     :"@xmlns:i"=>"http://www.w3.org/2001/XMLSchema-instance"},
   :@xmlns=>"http://tempuri.org/"}}
```


## LICENSE
See the LICENSE file.

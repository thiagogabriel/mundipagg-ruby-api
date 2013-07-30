MundiPagg Ruby Client Library
====================

[![Build Status](https://travis-ci.org/mundipagg/ruby-integration-api.png?branch=master)](https://travis-ci.org/mundipagg/ruby-integration-api)

[![Gem Version](https://badge.fury.io/rb/mundipagg.png)](http://badge.fury.io/rb/mundipagg)

Ruby API for integration with MundiPagg payment web services.

## Dependencies 
* [Savon 2.3.0](http://savonrb.com/version2/)
	* [Nori 2.3.0](https://github.com/savonrb/nori)

Unit tests made with [Cucumber](https://github.com/cucumber/cucumber) and [RSpec](https://github.com/rspec/rspec)

## Usage
Below a simple exemple of an order with one credit card transaction.

````Ruby
> gem install mundipagg
````

````Ruby
require 'mundipagg'

#Create the client instance
client = Mundipagg::MundiPaggClient.new :test #API test environment

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
credit.creditCardBrandEnum = CreditCardTransaction.BrandEnum[:Visa]
credit.creditCardOperationEnum = CreditCardTransaction.OperationEnum[:AuthAndCapture]
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
````

## More information

[RubyDoc](http://rubydoc.info/github/mundipagg/mundipagg-ruby-api/)

## LICENSE
See the LICENSE file.

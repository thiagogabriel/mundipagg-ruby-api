Feature: Boleto transaction
	I want to create a order with one boleto transaction.

	Scenario: Send a Boleto Transaction to One
		Given I have purchase two products with a total cost of BRL 50.00
		And I will pay using Boleto with 15 days to expire
		And I will send to Mundipagg 
		Then The order amount in cents should be 5000 
		And The boleto status should be Generated

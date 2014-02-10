Feature: Credit Card Transaction
	I want to create a order with one credit card transaction.

	Scenario: Pay a order using credit card and installment 
		Given I have purchase three products with a total cost of BRL 250
		And I will pay using a Visa credit card in 3 installments
		And I will send to Mundipagg 
		Then the order amount in cents should be 25000 
		And the transaction status should be Captured

	Scenario: Pay a order using credit card without installment
		Given I have purchase three products with a total cost of BRL 100,29
		And I will pay using a Visa credit card without installment
		And I will send to Mundipagg 
		Then the order amount in cents should be 10029
		And the transaction status should be Captured

	Scenario: Keeping sensible information unlogged
		Given I have purchase three products with a total cost of BRL 100,29
		And I will pay using a Visa credit card without installment
		And I will send to Mundipagg 
		Then the log file doesn't contain sensible information

Feature: Post Notification
	I want capture a transaction and receive a post notification telling my transaction has been captured.


	Scenario: Receiving a POST notification
		Given I have pre authorized a credit card transaction of BRL 100.00
		And I captured the transaction
		Then I will receive a POST notification telling my transaction has been Captured 
		And the amount captured should be BRL 100.00

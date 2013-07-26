class ManagerOrderRequest
	attr_accessor :transactionCollection, :manageOrderOperationEnum, :merchantKey,
					:orderKey, :orderReference, :requestKey

	def initialize
		@transactionCollection = Array.new
		@requestKey = '00000000-0000-0000-0000-000000000000'
	end

	@@Operation = {
		:Capture => 'Capture',
		:Void => 'Void'
	}

	def self.OperationEnum
		@@Operation
	end
end

class ManagerTransactionRequest
	attr_accessor :amountInCents, :transactionKey, :transactionReference
end
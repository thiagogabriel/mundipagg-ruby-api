class Buyer
	attr_accessor :buyerKey, :buyerReference, :email, :facebookId, :genderEnum, :homePhone,
					:ipAddress, :mobilePhone, :workPhone, :name, :personTypeEnum, :taxDocumentNumber, 
					:taxDocumentTypeEnum, :twitterId, :addressCollection


	@@Gender = {
		:Male => 'M',
		:Female => 'F'
	}

	@@PersonType = {
		:Person => 'Person',
		:Company => 'Company'
	}

	@@DocumentType = {
		:CPF => 'CPF',
		:CNPJ => 'CNPJ'
	}


	def initialize
		@addressCollection = Array.new
		@buyerKey = '00000000-0000-0000-0000-000000000000'
		@genderEnum = Buyer.GenderEnum[:Male]
		@personTypeEnum = Buyer.PersonTypeEnum[:Person]
		@taxDocumentTypeEnum = Buyer.DocumentTypeEnum[:CPF]
	end

	def self.GenderEnum
		@@Gender
	end

	def self.PersonTypeEnum
		@@PersonType
	end

	def self.DocumentTypeEnum
		@@DocumentType
	end
end


class BuyerAddress
	attr_accessor :addressTypeEnum, :city, :complement, :countryEnum,
					:district, :number, :state, :street, :zipCode

	@@AddressType={
		:Billing => 'Billing',
		:Shipping => 'Shipping',
		:Work => 'Comercial',
		:Home => 'Residential'
	}


	@@Country = {
		:Brazil => 'Brazil',
		:UnitedStates => 'USA',
		:Argentina => 'Argentina',
		:Bolivia => 'Bolivia',
		:Chile => 'Chile',
		:Colombia => 'Colombia',
		:Uruguay => 'Uruguay',
		:Mexico => 'Mexico',
		:Paraguay => 'Paraguay'
	}

	def initialize
		@addressTypeEnum = BuyerAddress.AddressTypeEnum[:Home]
		@countryEnum = BuyerAddress.CountryEnum[:Brazil]
	end

	def self.AddressTypeEnum
		@@AddressType
	end

	def self.CountryEnum
		@@Country
	end

end
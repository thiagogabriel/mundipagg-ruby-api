class BuyerAddress

	# @return [String] Address Type.
	# @see AddressTypeEnum
	# @param Default: Residential
	attr_accessor :addressTypeEnum 
	# @return [String] City.
	attr_accessor :city
	# @return [String] Address complement.
	attr_accessor :complement 
	# @return [String] Address country.
	# @param Default: Brazil
	# @see CountryEnum
	attr_accessor :countryEnum
	# @return [String] District.
	attr_accessor :district 
	# @return [String] Address number.
	attr_accessor :number 
	# @return [String] Address state.
	attr_accessor :state 
	# @return [String] Street.
	attr_accessor :street
	# @return [String] Zip Code.
	attr_accessor :zipCode


	#Address Type Enum
	@@ADDRESS_TYPE={
		:Billing => 'Billing',
		:Shipping => 'Shipping',
		:Work => 'Comercial',
		:Home => 'Residential'
	}


	# Country Enum
	@@COUNTRY = {
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

	#Initialize class with properties
	def initialize
		@addressTypeEnum = BuyerAddress.AddressTypeEnum[:Home]
		@countryEnum = BuyerAddress.CountryEnum[:Brazil]
	end

	#Address Type Enum
	# @see @@ADDRESS_TYPE
	def self.AddressTypeEnum
		@@ADDRESS_TYPE
	end

	# Country Enum
	# @see @@COUNTRY
	def self.CountryEnum
		@@COUNTRY
	end

end
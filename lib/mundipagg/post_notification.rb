require 'Nori'

module Mundipagg
	# Class who handles Mundipagg post notification XML
	class PostNotification
	
	    # This method parse the Xml sent by Mundipagg when notify a change in a transaction.
	    # 
	    # @param request [String] XML received in the Mundipagg POST request.
	    # @return [Hash<Symbol, String>] A hash collection containing the XML data parsed.
		def self.ParseNotification(xml)

			nori = Nori.new(:convert_tags_to => lambda { |tag| PostNotification.to_underscore(tag).to_sym })
			xml_hash  = nori.parse(xml)

			return xml_hash
		end

		# Converts a string in Camel Case format to lower case with underscore.
		#
		# @param Example: 'StatusNotification' outputs 'status_notification'
		# @returns [String] lower case string separated with underscore
		def self.to_underscore(camel_case_string)
			return camel_case_string.gsub(/::/, '/').
				gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
				gsub(/([a-z\d])([A-Z])/,'\1_\2').
				tr("-", "_").
				downcase
		end
	end
end
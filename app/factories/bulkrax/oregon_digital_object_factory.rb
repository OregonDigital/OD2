module Bulkrax
	class OregonDigitalObjectFactory < ObjectFactory
		
		# Override to add the _attributes properties
		def permitted_attributes
			attribute_properties + super
		end

		# Gather the attribute_properties
		def attribute_properties
			klass.properties.keys.map { |k| "#{k}_attributes".to_sym unless klass.properties[k].class_name.nil? }.compact
		end
	end
end
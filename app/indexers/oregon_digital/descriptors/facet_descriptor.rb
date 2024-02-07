module OregonDigital
  module Descriptors
    class FacetDescriptor < ActiveFedora::Indexing::Descriptor
      attr_reader :index_type
      def initialize(*args)
        if args.last.is_a? Hash
          opts = args.pop
          @converter = opts[:converter]
          @type_required = opts[:requires_type]
        end
        @index_type = args
        raise InvalidIndexDescriptor, "Invalid index type passed.  It should be an array like [:string, :indexed, :stored, :multivalued]. You provided: `#{@index_type}'" unless index_type.is_a? Array
      end

      def name_and_converter(field_name, args = nil)
        args ||= {}
        field_type = args[:type]
        if type_required?
          raise ArgumentError, "Must provide a :type argument when index_type is `#{self}' for #{field_name}" unless field_type
        end
        ["#{field_name.to_s}_s_lower_m", converter(field_type)]
      end

      def type_required?
        @type_required
      end

      def evaluate_suffix(field_type)
        ActiveFedora::Indexing::Suffix.new([:string, :multivalued])
      end

      protected

        # Suffix can be overridden if you want a different method of grabbing the suffix
        def suffix(field_type)
          evaluate_suffix(field_type).to_s
        end

        def converter(field_type)
          @converter.call(field_type) if @converter
        end
    end
  end
end
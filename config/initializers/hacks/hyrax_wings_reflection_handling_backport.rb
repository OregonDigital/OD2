# frozen_string_literal: true

# This is a backport of PR #6298: https://github.com/samvera/hyrax/pull/6298
# This is intended to speed up Reflections in ActiveFedora when translating to a Valkyrie::Resource
# The main motivation for this is to speed up access to #member_ids on AdminSets when converting to Valkyrie::Resource
# This code can be removed once we are on Hyrax >v5.0.0 or Hyrax backports this code itself to our current version
Rails.application.config.to_prepare do
  Wings::AttributeTransformer.class_eval do
    def self.run(obj) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      attrs = obj.reflections.each_with_object({}) do |(key, reflection), mem| # rubocop:disable Metrics/BlockLength
        case reflection
        when ActiveFedora::Reflection::BelongsToReflection, # uses foreign_key SingularRDFPropertyReflection
             ActiveFedora::Reflection::BasicContainsReflection, # ???
             ActiveFedora::Reflection::FilterReflection, # rely on :extending_from
             ActiveFedora::Reflection::HasAndBelongsToManyReflection, # uses foreign_key RDFPropertyReflection
             ActiveFedora::Reflection::HasManyReflection, # captured by inverse relation
             ActiveFedora::Reflection::HasSubresourceReflection, # ???
          :noop
        when ActiveFedora::Reflection::OrdersReflection
          mem[:"#{reflection.options[:unordered_reflection].name.to_s.singularize}_ids"] ||= []
          mem[:"#{reflection.options[:unordered_reflection].name.to_s.singularize}_ids"] +=
            obj.association(reflection.name).target_ids_reader
        when ActiveFedora::Reflection::DirectlyContainsOneReflection
          mem[:"#{key.to_s.singularize}_id"] =
            obj.public_send(reflection.name)&.id
        when ActiveFedora::Reflection::IndirectlyContainsReflection
          mem[:"#{key.to_s.singularize}_ids"] ||= []
          mem[:"#{key.to_s.singularize}_ids"] +=
            obj.association(key).ids_reader
        when ActiveFedora::Reflection::DirectlyContainsReflection
          mem[:"#{key.to_s.singularize}_ids"] ||= []
          mem[:"#{key.to_s.singularize}_ids"] +=
            Array(obj.public_send(reflection.name)).map(&:id)
        when ActiveFedora::Reflection::RDFPropertyReflection
          mem[reflection.name.to_sym] =
            obj.public_send(reflection.name.to_sym)
        else
          raise NotImplementedError, "Expected a known ActiveFedora::Reflection, but got #{reflection}"
        end
      end

      obj.class.delegated_attributes.keys.each_with_object(attrs) do |attr_name, mem|
        next unless obj.respond_to?(attr_name) && !mem.key?(attr_name.to_sym)
        mem[attr_name.to_sym] = Wings::TransformerValueMapper.for(obj.public_send(attr_name)).result
      end
    end
  end

  Wings::ModelTransformer.class_eval do
    ##
    # Builds a `Valkyrie::Resource` equivalent to the `pcdm_object`
    #
    # @return [::Valkyrie::Resource] a resource mirroring `pcdm_object`
    # rubocop:disable Metrics/AbcSize
    def build
      klass = cache.fetch(pcdm_object.class) do
        Wings::OrmConverter.to_valkyrie_resource_class(klass: pcdm_object.class)
      end

      mint_id unless pcdm_object.id

      attrs = attributes.tap { |hash| hash[:new_record] = pcdm_object.new_record? }
      attrs[:alternate_ids] = [::Valkyrie::ID.new(pcdm_object.id)] if pcdm_object.id

      klass.new(**attrs).tap do |resource|
        resource.lease = pcdm_object.lease&.valkyrie_resource if pcdm_object.respond_to?(:lease) && pcdm_object.lease
        resource.embargo = pcdm_object.embargo&.valkyrie_resource if pcdm_object.respond_to?(:embargo) && pcdm_object.embargo
        check_size(resource)
        check_pcdm_use(resource)
        ensure_current_permissions(resource)
      end
    end

    def check_size(resource)
      return unless resource.respond_to?(:recorded_size) && pcdm_object.respond_to?(:size)
      resource.recorded_size = [pcdm_object.size.to_i]
    end

    def check_pcdm_use(resource)
      return unless resource.respond_to?(:pcdm_use) &&
                    pcdm_object.respond_to?(:metadata_node) &&
                    pcdm_object&.metadata_node&.respond_to?(:type)
      resource.pcdm_use = pcdm_object.metadata_node.type.to_a
    end

    private

    def additional_attributes
      { :id => pcdm_object.id,
        :created_at => pcdm_object.try(:create_date),
        :updated_at => pcdm_object.try(:modified_date),
        ::Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK => lock_token }
    end

  end

  Wings::OrmConverter.class_eval do
    ##
    # @param klass [Class] an `ActiveFedora` model class
    #
    # @return [Class] a dyamically generated `Valkyrie::Resource` subclass
    #   mirroring the provided `ActiveFedora` model
    #
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/BlockLength
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength because metaprogramming a class
    #   results in long methods
    def self.to_valkyrie_resource_class(klass:)
      Class.new(base_for(klass: klass)) do
        # store a string we can resolve to the internal resource
        @internal_resource = klass.try(:to_rdf_representation) || klass.name

        class << self
          attr_reader :internal_resource

          def name
            _canonical_valkyrie_model&.name
          end

          ##
          # @return [String]
          def to_s
            internal_resource
          end

          ##
          # @api private
          def _canonical_valkyrie_model
            ancestors[1..-1].find { |parent| parent < ::Valkyrie::Resource }
          end
        end

        ##
        # @return [URI::GID]
        def to_global_id
          URI::GID.build([GlobalID.app, internal_resource, id, {}])
        end

        ##
        # @return [ActiveModel::Base]
        def to_model
          model_class = internal_resource.safe_constantize || self

          Hyrax::ActiveFedoraDummyModel.new(model_class, id)
        end

        klass.properties.each_key do |property_name|
          next if fields.include?(property_name.to_sym)

          if klass.properties[property_name].multiple?
            attribute property_name.to_sym, ::Valkyrie::Types::Set.of(::Valkyrie::Types::Anything).optional
          else
            attribute property_name.to_sym, ::Valkyrie::Types::Anything.optional
          end
        end

        # add reflection associations
        (klass.try(:reflections) || []).each do |reflection_key, reflection|
          case reflection
          when ActiveFedora::Reflection::BelongsToReflection, # uses foreign_key SingularRDFPropertyReflection
               ActiveFedora::Reflection::BasicContainsReflection, # ???
               ActiveFedora::Reflection::FilterReflection, # rely on :extending_from
               ActiveFedora::Reflection::HasAndBelongsToManyReflection, # uses foreign_key RDFPropertyReflection
               ActiveFedora::Reflection::HasManyReflection, # captured by inverse relation
               ActiveFedora::Reflection::HasSubresourceReflection, # ???
               ActiveFedora::Reflection::OrdersReflection # map to :unordered_association in Wings::AttributeTransformer (but retain order)
            next
          when ActiveFedora::Reflection::DirectlyContainsOneReflection
            attribute_name = (reflection_key.to_s.singularize + '_id').to_sym
            type = ::Valkyrie::Types::ID.optional
          when ActiveFedora::Reflection::DirectlyContainsReflection,
               ActiveFedora::Reflection::IndirectlyContainsReflection
            attribute_name = (reflection_key.to_s.singularize + '_ids').to_sym
            type = ::Valkyrie::Types::Set.of(::Valkyrie::Types::ID)
          when ActiveFedora::Reflection::SingularRDFPropertyReflection
            attribute_name = reflection.name.to_sym
            type = ::Valkyrie::Types::ID.optional
          when ActiveFedora::Reflection::RDFPropertyReflection
            attribute_name = reflection.name.to_sym
            type = ::Valkyrie::Types::Set.of(::Valkyrie::Types::ID)
          else
            raise NotImplementedError, "Expected a known ActiveFedora::Reflection, but got #{reflection}"
          end

          attribute(attribute_name, type)
        end

        def internal_resource
          self.class.internal_resource
        end
      end
    end
  end
end

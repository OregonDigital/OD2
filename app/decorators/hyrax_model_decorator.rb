class HyraxModelDecorator < SimpleDelegator

  def initialize(model)
    @valkyrie_model = model.class.to_s.gsub('Hyrax', 'Valkyrie').camelcase.constantize
    @hyrax = model
    @valkyrie = @valkyrie_model.new
    super(@hyrax)
  end

  def save
    @hyrax.attributes.with_indifferent_access.each_pair do |k, v|
      @valkyrie.send("#{k}=", v) if @valkyrie.respond_to? "#{k}="
    end
    @valkyrie.hasModel = @hyrax.class.to_s
    adapter = Valkyrie::MetadataAdapter.find(:fedora)
    object = adapter.persister.save(resource: @valkyrie)
    @hyrax.attributes = object.attributes_for_hyrax
    @hyrax
  end
end

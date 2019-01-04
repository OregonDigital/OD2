# frozen_string_literal:true

module OregonDigital::TriplePoweredProperties::Inputs
  ##
  # Levered hydra-editors multi_value input field to handle triple powered properties label fetching
  # and rendering
  class TriplePoweredPropertyInput < SimpleForm::Inputs::CollectionInput
    ##
    # Render the input field as a multi_value or single field
    #
    # @param wrapper_options [Hash] the hash supplied by the partial
    def input(_wrapper_options)
      @rendered_first_element = false
      input_html_classes.unshift('string')
      input_html_options[:name] ||= "#{object_name}[#{attribute_name}][]"

      build_wrapper_html(input_options)

      # Render the multiple or a single field for this TriplePoweredPropertyInput
      input_options[:multi_value] ? render_multi : render_field(collection.first, 0)
    end

    protected

    ##
    # Renders a single field
    #
    # @param value [String] the value of the property
    # @param index [Integer] the index of the field being rendered
    def render_field(value, index)
      html = build_field(value, index)
      html += build_label(value)
      html += "<div class='message has-warning hidden'></div>".html_safe
      html
    end

    ##
    # Wraps a collection of single fields in a UL
    def render_multi
      outer_wrapper do
        buffer_each(collection) do |value, index|
          inner_wrapper do
            render_field(value, index)
          end
        end
      end
    end

    def buffer_each(collection)
      collection.each_with_object('').with_index do |(value, buffer), index|
        buffer << yield(value, index)
      end
    end

    ##
    # The outer UL wrapping a list of fields
    def outer_wrapper
      "    <ul class=\"listing\">\n        #{yield}\n      </ul>\n"
    end

    ##
    # The LI wrapping each individual field
    def inner_wrapper
      <<-HTML
          <li class="field-wrapper">
            #{yield}
          </li>
      HTML
    end

    private

    ##
    # Although the 'index' parameter is not used in this implementation it is useful in an
    # an overridden version of this method, especially when the field is a complex object and
    # the override defines nested fields.
    def build_field_options(value, _index)
      options = input_html_options.dup
      options[:value] = value
      if @rendered_first_element
        options[:id] = nil
        options[:required] = nil
      else
        options[:id] ||= input_dom_id
      end
      options[:class] ||= []
      options[:class] += ["#{input_dom_id} form-control multi-text-field"]
      options[:'aria-labelledby'] = label_id
      @rendered_first_element = true
      options
    end

    ##
    # ActionView builds the appropriate TEXTAREA or INPUT nodes
    #
    # @param value [String] the property value
    # @param index [Integer] the index of this property value
    def build_field(value, index)
      options = build_field_options(value, index)
      if options.delete(:type) == 'textarea'
        @builder.text_area(attribute_name, options)
      else
        @builder.text_field(attribute_name, options)
      end
    end

    ##
    # Build the triple powered property label interface with the preferred label displayed and a collapsable list
    # containing the remaining labels.
    #
    # The labels include microdata for search engines
    #
    # @param uri [String] the uri to the RDF resource containing the labels
    def build_label(uri)
      return label_html.html_safe if uri.blank?

      begin
        graph = OregonDigital::TriplePoweredProperties::Triplestore.fetch(uri)
        predicate_labels = OregonDigital::TriplePoweredProperties::Triplestore.predicate_labels(graph)
      rescue TriplestoreAdapter::TriplestoreException
        return error_html.html_safe
      end

      uri_html(uri, predicate_labels).html_safe
    end

    def label_html
      "<div itemscope itemtype='' class='triple_powered_labels hidden' data-rdf-uri=''></div>"
    end

    def error_html
      "<div class='triple_powered_labels'><span class='error'>Failed to fetch labels for this URL.</span></div>"
    end

    def uri_html(uri, predicate_labels)
      built_labels = build_label_list(predicate_labels, uri)
      "<div itemscope itemtype='#{uri}' class='triple_powered_labels' data-rdf-uri='#{uri}'>#{built_labels}</div>"
    end

    ##
    # Iterate through each of the predicate_labels and generate a SPAN for each
    #
    # @param predicate_labels [Hash] the predicate and each of the labels
    # @param uri [String] the RDF endpoint containing the labels
    def build_label_list(predicate_labels, uri)
      count = predicate_labels.values.flatten.size
      return "<span itemprop='uri'>#{uri}</span>" if count.zero?

      spans = []
      predicate_labels.each_pair do |k, v|
        spans << v.map { |label| "<span itemtype='#{k}' itemprop='label'>#{label}</span>" }
      end
      spans.flatten!

      first_span = spans.delete_at(0)
      return first_span if spans.size.zero?

      set_label_html(count, first_span, spans)
    end

    def set_label_html(count, first_span, spans)
      <<-HTML
        <span class='toggle badge'
          data-show-all="Show all labels. (#{count})"
          data-hide-all="Hide labels.">Show all labels. (#{count})</span>
        #{first_span}
        <ul class='list'>
          <li>
            #{spans.join('</li><li>')}
          </li>
        </ul>
      HTML
    end

    ##
    # Create an id
    def label_id
      input_dom_id + '_label'
    end

    ##
    # Create a dom id
    def input_dom_id
      input_html_options[:id] || "#{object_name}_#{attribute_name}"
    end

    def collection
      @collection ||= Array.wrap(object[attribute_name]).reject { |value| value.to_s.strip.blank? } + ['']
    end

    def multiple?
      true
    end

    def build_wrapper_html(input_options)
      # ensure the multi_value class is included if it was provided as part of the options
      input_options[:wrapper_html] ||= { class: '' }
      input_options[:wrapper_html][:class] += input_options[:multi_value] ? ' multi_value' : ''
    end
  end
end

# frozen_string_literal:true

module OregonDigital
  module CitationsBehaviors
    # Behavior to format places of publication
    module PublicationBehavior
      include Hyrax::CitationsBehaviors::CommonBehavior
      include Hyrax::CitationsBehaviors::PublicationBehavior

      # OVERRIDE HYRAX to default to access date if no published date present
      def setup_pub_date(work)
        date_value = super(work)
        clean_end_punctuation(Time.now.strftime('%d %b %Y')) unless date_value
      end

      # OVERRIDE HYRAX to set Oregon Digital as publisher
      def setup_pub_publisher
        'Oregon Digital'
      end

      # OVERRIDE HYRAX to order and punctuate publisher information correctly
      def setup_pub_info(work, include_date = false)
        pub_info = ''
        if (publisher = setup_pub_publisher)
          pub_info += CGI.escapeHTML(publisher)
        end

        pub_date = include_date ? setup_pub_date(work) : nil
        pub_info += ', ' + pub_date unless pub_date.nil?

        pub_info.strip!
        pub_info.blank? ? nil : pub_info
      end
    end
  end
end

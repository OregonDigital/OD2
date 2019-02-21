# frozen_string_literal: true

module Qa::Authorities
  # Format QA Object
  class Format < Qa::Authorities::Base

    self.label = lambda do |item|
      [item].compact.join(', ')
    end

    def search(q)
      if OregonDigital::ControlledVocabularies::MediaType.in_vocab?(q)
        parse_authority_response(find_term(json(q), q))
      else
        []
      end
    end
  end
end

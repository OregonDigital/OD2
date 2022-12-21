# frozen_string_literal: true

# Getty AAT places the ID in an unusual spot in the response
module GettyAatParsingBehavior
  private

  def parse_authority_response(term, vocabulary)
    id = (term.first['id'] || term.first['@id'].to_s) if term.first.is_a?(Hash)
    [{ 'id' => id,
       'label' => label.call(term, vocabulary) }]
  end
end

# frozen_string_literal:true

RSpec.describe OregonDigital::VERSION do
  let(:special) { "?<>',?[]}{=)(*&^%$#`~{}" }
  # Makes a big regex of escaped special characters that aren't allowed in the version number
  let(:regex) { /[#{special.gsub(/./) { |char| "\\#{char}" }}]/ }

  it { is_expected.not_to match(regex) }
end

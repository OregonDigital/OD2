require 'rails_helper'

RSpec.describe OembedError, type: :model do
  let(:error) { "ERROR ERROR ERROR" }

  it 'initializes oembed_url as an array' do
    expect(subject.oembed_errors).to be_an_instance_of(Array)
  end

  it 'stores only unique errors' do
    subject.oembed_errors << error
    subject.oembed_errors << error

    expect(subject.oembed_errors.count).to eq(2)

    subject.run_callbacks :save

    expect(subject.oembed_errors.count).to eq(1)
  end
end

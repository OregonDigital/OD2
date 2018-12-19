# frozen_string_literal:true

RSpec.describe 'Oembed Provider Initialization' do
  it 'registers https://media.oregonstate.edu/id*' do
    let(:provider) do
      OEmbed::Providers.find('https://media.oregonstate.edu/id/test')
    end

    expect(provider).not_to be_nil
  end

  it 'registers https://media.oregonstate.edu/media/id*' do
    let(:provider) do
      OEmbed::Providers.find('https://media.oregonstate.edu/media/id/test')
    end

    expect(provider).not_to be_nil
  end

  it 'registers https://media.oregonstate.edu/media/t*' do
    let(:provider) do
      OEmbed::Providers.find('https://media.oregonstate.edu/media/t/test')
    end

    expect(provider).not_to be_nil
  end
end

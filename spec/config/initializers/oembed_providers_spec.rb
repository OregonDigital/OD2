# frozen_string_literal:true

RSpec.describe 'Oembed Provider Initialization' do
  it 'registers https://media.oregonstate.edu/id*' do
    expect(
      OEmbed::Providers.find('https://media.oregonstate.edu/id/test')
    ).not_to be_nil
  end

  it 'registers https://media.oregonstate.edu/media/id*' do
    expect(
      OEmbed::Providers.find('https://media.oregonstate.edu/media/id/test')
    ).not_to be_nil
  end

  it 'registers https://media.oregonstate.edu/media/t*' do
    expect(
      OEmbed::Providers.find('https://media.oregonstate.edu/media/t/test')
    ).not_to be_nil
  end
end

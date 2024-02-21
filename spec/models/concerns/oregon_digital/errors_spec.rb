# frozen_string_literal:true

RSpec.describe OregonDigital::Errors do
  let(:item) { build(:generic, title: ['Bullwinkle'], depositor: user.email) }
  let(:user) { create(:user) }

  after do
    item.remove_errors('borked')
  end

  describe 'add' do
    it 'adds the error' do
      item.add_error('borked', 'my bad')
      expect(item.all_errors).to eq({ borked: ['my bad'] })
      expect(item.error_keys).to eq(["hyrax:Generic:#{item.id}:errors:borked"])
    end
  end

  describe 'remove' do
    before do
      item.add_error('barking', 'mad')
    end

    it 'removes the error' do
      item.remove_errors('barking')
      expect(item.all_errors).to eq({})
    end
  end
end

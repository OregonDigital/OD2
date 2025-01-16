# frozen_string_literal: true

RSpec.describe OregonDigital::Notification do
  let(:notifier) { described_class.new }
  let(:query_resp1) do
    {
      'has_model_ssim' => ['Document'],
      'id' => 'abcde1234',
      'depositor_ssim' => ['mika@uosu.edu'],
      'thumbnail_path_ss' => '/downloads/f0abcde1234?file=thumbnail'
    }
  end
  let(:query_resp2) do
    {
      'id' => 'ghijk9876',
      'depositor_ssim' => ['mika@uosu.edu']
    }
  end

  describe 'add_review_items' do
    before do
      allow(Hyrax::SolrService).to receive(:query).and_return([query_resp1])
    end

    it 'adds review items to the map' do
      notifier.add_review_items
      expect(notifier.user_map['mika@uosu.edu'][:reviews]).to eq(['abcde1234'])
      expect(notifier.build_message(notifier.user_map['mika@uosu.edu'])).to eq('reviews: 1')
    end
  end

  describe 'add_change_items' do
    before do
      allow(Hyrax::SolrService).to receive(:query).and_return([query_resp2])
    end

    it 'adds change items to the map' do
      notifier.add_change_items
      expect(notifier.user_map['mika@uosu.edu'][:changes]).to eq(['ghijk9876'])
      expect(notifier.build_message(notifier.user_map['mika@uosu.edu'])).to eq('changes: 1')
    end
  end

  describe 'get_time_window' do
    let(:now) { Time.new.utc }

    before do
      allow(Time).to receive(:new).and_return(now)
    end

    it 'returns 2 timestrings separated by a span' do
      span = (60 * 60 * 24)
      t_test = now - (60 * 60 * 25)
      time = notifier.get_time_window(span)
      tstart = Time.parse(time[0])
      tend = Time.parse(time[1])
      now_arr = now.to_a.slice(1, 9) # convert to an array but remove the seconds
      tend_arr = tend.to_a.slice(1, 9) # as above
      expect(now_arr).to eq(tend_arr)
      expect(t_test.between?(tstart, tend)).to be(false)
    end
  end

  describe 'simple_derivative_check' do
    let(:path1) { { 'thumbnail_path_ss' => '/downloads/f0abcde1234?file=thumbnail' } }
    let(:path2) { { 'thumbnail_path_ss' => '/assets/work-12345678987654321abcdefg.png' } }
    let(:path3) { { 'id' => 'abcde1234' } }

    it 'checks the thumbnail path' do
      expect(notifier.simple_derivative_check(path1)).to eq(true)
      expect(notifier.simple_derivative_check(path2)).to eq(false)
      expect(notifier.simple_derivative_check(path3)).to eq(false)
    end
  end
end

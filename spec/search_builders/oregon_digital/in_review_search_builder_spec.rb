# frozen_string_literal:true

RSpec.describe OregonDigital::InReviewSearchBuilder do
  let(:context) { double }
  let(:search_builder) { described_class.new(context) }

  describe '#processor_chain' do
    subject { processor_chain }

    let(:processor_chain) { search_builder.processor_chain }

    it { is_expected.to include(:actionable, :not_deposited) }
  end

  describe '#actionable' do
    subject { solr_params }

    let(:solr_params) { {} }

    before { search_builder.actionable(solr_params) }

    it { is_expected.to eq(fq: ['{!terms f=actionable_workflow_roles_ssim}']) }
  end

  describe '#not_deposited' do
    subject { solr_params }

    let(:solr_params) { {} }

    before { search_builder.not_deposited(solr_params) }

    it { is_expected.to eq(fq: ['-workflow_state_name_ssim:deposited']) }
  end
end

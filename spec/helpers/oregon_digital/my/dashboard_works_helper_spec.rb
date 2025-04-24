# frozen_string_literal: true

RSpec.describe OregonDigital::My::DashboardWorksHelper do
  # INCLUDE: include the module so we can call its methods directly
  include described_class

  # TEST GROUP: Test on whether the label return correctly
  describe '#workflow_state_display' do
    it 'returns "Published" for "deposited"' do
      expect(workflow_state_display('deposited')).to eq('Published')
    end

    it 'returns "Under Review" for "pending_review"' do
      expect(workflow_state_display('pending_review')).to eq('Under Review')
    end

    it 'returns "Tombstoned" for "tombstoned"' do
      expect(workflow_state_display('tombstoned')).to eq('Tombstoned')
    end

    it 'fallbacks to titleized value for unknown keys' do
      expect(workflow_state_display('archived')).to eq('Archived')
    end
  end
end

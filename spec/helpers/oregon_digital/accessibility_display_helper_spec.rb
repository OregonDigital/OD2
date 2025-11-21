# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OregonDigital::AccessibilityDisplayHelper do
  describe '#accessibility_display' do
    it 'humanizes camelCase words' do
      expect(helper.accessibility_display('pageBreakMarkers')).to eq('Page Break Markers')
    end

    it 'helps preserves known acronyms exactly' do
      expect(helper.accessibility_display('ChemML')).to eq('ChemML')
      expect(helper.accessibility_display('MathML')).to eq('MathML')
      expect(helper.accessibility_display('PDF')).to eq('PDF')
    end

    it 'capitalizes words after acronyms correctly' do
      expect(helper.accessibility_display('MathML-chemistry')).to eq('MathML-Chemistry')
      expect(helper.accessibility_display('MathMLSomething')).to eq('MathML Something')
    end
  end
end

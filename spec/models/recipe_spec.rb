require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe '#valid?' do
    subject(:recipe) { described_class.new(title: 'Cookie dought', author: author) }

    context 'when all required attributes are provided' do
      let(:author) { 'Xander' }

      it { is_expected.to be_valid }
    end

    context 'when a required attribute is missing' do
      let(:author) { nil }

      it { is_expected.to_not be_valid }
    end
  end
end

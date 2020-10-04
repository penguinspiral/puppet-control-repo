require 'spec_helper'

describe 'profiles::bootstrap', type: :class do
  context 'when default' do
    it { is_expected.to contain_class('profiles::bootstrap::node') }
    it { is_expected.not_to contain_class('profiles::bootstrap::seed') }
    it { is_expected.to compile }
  end

  context 'when ::seed true' do
    let :params do
      {
        seed: true,
      }
    end

    it { is_expected.to contain_class('profiles::bootstrap::node') }
    it { is_expected.to contain_class('profiles::bootstrap::seed') }
    it { is_expected.to compile }
  end

  context 'when ::seed invalid' do
    invalid = [123, 'string', [1, 2, 3], { key: 'value' }]
    invalid.each do |input|
      context "when ::seed #{input}" do
        let :params do
          {
            seed: input,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Boolean}) }
        it { is_expected.not_to compile }
      end
    end
  end
end

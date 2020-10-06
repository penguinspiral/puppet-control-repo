require 'spec_helper'

describe 'profiles::bootstrap::node', type: :class do
  context 'when default' do
    it { is_expected.to compile }
    it { is_expected.to contain_class('profiles::bootstrap::node::agent') }
    it { is_expected.to contain_class('profiles::bootstrap::node::master') }
  end

  context 'when ::serverless false' do
    let :params do
      {
        serverless: false,
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_class('profiles::bootstrap::node::agent') }
    it { is_expected.not_to contain_class('profiles::bootstrap::node::master') }
  end

  context 'when ::serverless invalid' do
    invalid = [123, 'string', [1, 2, 3], { key: 'value' }]
    invalid.each do |input|
      context "when ::serverless #{input}" do
        let :params do
          {
            serverless: input,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Boolean}) }
        it { is_expected.not_to compile }
      end
    end
  end
end

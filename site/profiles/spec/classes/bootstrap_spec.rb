require 'spec_helper'

describe 'profiles::bootstrap', type: :class do
  context 'when default' do
    it { is_expected.to contain_class('profiles::bootstrap::agent') }
    it { is_expected.to contain_class('profiles::bootstrap::server') }
    it { is_expected.to compile }
  end

  context 'when ::serverless valid' do
    context 'when ::serverless true' do
      let :params do
        {
          serverless: true,
        }
      end

      it { is_expected.to contain_class('profiles::bootstrap::agent') }
      it { is_expected.to contain_class('profiles::bootstrap::server') }
      it { is_expected.to compile }
    end
    context 'when ::serverless false' do
      let :params do
        {
          serverless: false,
        }
      end

      it { is_expected.to contain_class('profiles::bootstrap::agent') }
      it { is_expected.not_to contain_class('profiles::bootstrap::server') }
      it { is_expected.to compile }
    end
  end

  context 'when ::serverless invalid' do
    invalid = [0, 'seed.raft.com', ['seed', 'hygon'], { server: 'localhost' }]
    invalid.each do |serverless|
      context "when ::serverless #{serverless}" do
        let :params do
          {
            serverless: serverless,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Boolean}) }
        it { is_expected.not_to compile }
      end
    end
  end
end

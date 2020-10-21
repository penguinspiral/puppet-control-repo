require 'spec_helper'

describe 'profiles::network', type: :class do
  context 'when default' do
    it { is_expected.to contain_class('network') }
    it { is_expected.to have_network__interface_resource_count(0) }
    it { is_expected.to compile }
  end

  context 'when ::interfaces valid' do
    interfaces =
      {
        eno1: {
          ipaddress:       '192.168.0.2',
          netmask:         '255.255.0.0',
          gateway:         '192.168.0.1',
          dns_nameservers: '192.168.0.2 8.8.8.8 8.8.4.4',
          dns_search:      'raft.com',
        },
      }
    let :params do
      {
        interfaces: interfaces,
      }
    end

    it { is_expected.to contain_class('network') }
    # Network::Interface['lo'] automatically defined when not explicitly defined
    it { is_expected.to have_network__interface_resource_count(2) }
    it { is_expected.to contain_network__interface('lo') }
    it { is_expected.to contain_network__interface('eno1').with(interfaces[:eno1]) }
    it { is_expected.to compile }
  end

  context 'when ::interfaces invalid' do
    invalid = [123, 'string', [1, 2, 3], true]
    invalid.each do |interface|
      context "when ::interfaces #{interface}" do
        let :params do
          {
            interfaces: interface,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Hash}) }
        it { is_expected.not_to compile }
      end
    end
  end
end

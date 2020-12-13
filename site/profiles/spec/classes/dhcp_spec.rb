require 'spec_helper'

describe 'profiles::dhcp', type: :class do
  context 'when default' do
    dhcpd_default_config =
      [
        '/etc/dhcp',
        '/etc/default/isc-dhcp-server',
      ]
    dhcpd_concat_config =
      [
        '/etc/dhcp/dhcpd.conf',
        '/etc/dhcp/dhcpd.pools',
        '/etc/dhcp/dhcpd.ignoredsubnets',
        '/etc/dhcp/dhcpd.hosts',
      ]
    it { is_expected.to contain_class('dhcp') }
    it { is_expected.to contain_package('isc-dhcp-server').with('ensure' => 'installed') }
    it { is_expected.to contain_service('isc-dhcp-server').with('ensure' => 'stopped') }
    it { is_expected.to have_file_resource_count(dhcpd_default_config.length) }
    dhcpd_default_config.each do |file|
      it {
        is_expected.to contain_file(file).with(
          path: file,
        )
      }
    end
    it { is_expected.to have_concat_file_resource_count(dhcpd_concat_config.length) }
    dhcpd_concat_config.each do |file|
      it {
        is_expected.to contain_concat_file(file).with(
          path: file,
        )
      }
    end
    it { is_expected.to compile }
  end

  context 'when ::service_ensure valid' do
    # Stdlib::Ensure::Service
    valid = ['running', 'stopped']
    valid.each do |service_ensure|
      context "when ::service_ensure #{service_ensure}" do
        let :params do
          {
            service_ensure: service_ensure,
          }
        end

        it { is_expected.to contain_service('isc-dhcp-server').with('ensure' => service_ensure) }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::service_ensure invalid' do
    invalid = [123, 'string', [1, 2, 3], true]
    invalid.each do |service_ensure|
      context "when ::service_ensure #{service_ensure}" do
        let :params do
          {
            service_ensure: service_ensure,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Stdlib::Ensure::Service }) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::interfaces valid' do
    interfaces = ['eno1', 'eno2']
    context "when ::interfaces #{interfaces}" do
      let :params do
        {
          interfaces: interfaces,
        }
      end

      it {
        is_expected.to contain_file('/etc/default/isc-dhcp-server').with(
          ensure: 'file',
          content: %r{INTERFACESv4="#{interfaces.join(" ")}"},
        )
      }
      it { is_expected.to compile }
    end
  end

  context 'when ::interfaces invalid' do
    invalid = [123, 'string', true, { interfaces: 'eno1' }]
    invalid.each do |interfaces|
      context "when ::interfaces #{interfaces}" do
        let :params do
          {
            interfaces: interfaces,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects an Array}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::dnsdomain valid' do
    dnsdomain = ['raft.com', 'example.com']
    context "when ::dnsdomain #{dnsdomain}" do
      let :params do
        {
          dnsdomain: dnsdomain,
        }
      end

      it {
        is_expected.to contain_concat_fragment('dhcp-conf-header').with(
          content: %r{option domain-name "#{dnsdomain[0]}"},
        )
      }
      it { is_expected.to compile }
    end
  end

  context 'when ::dnsdomain invalid' do
    invalid = [123, 'string', true, { dnsdomain: 'raft.com' }]
    invalid.each do |dnsdomain|
      context "when ::dnsdomain #{dnsdomain}" do
        let :params do
          {
            dnsdomain: dnsdomain,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects an Array}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::nameservers valid' do
    nameservers = ['8.8.8.8', '8.8.4.4', '1.1.1.1']
    context "when ::nameservers #{nameservers}" do
      let :params do
        {
          nameservers: nameservers,
        }
      end

      it {
        is_expected.to contain_concat_fragment('dhcp-conf-header').with(
          content: %r{option domain-name-servers #{nameservers.join(", ")};},
        )
      }
      it { is_expected.to compile }
    end
  end

  context 'when ::nameservers invalid' do
    invalid = [123, 'string', true, { nameservers: ['google.dns', 'cloudflare.dns'] }]
    invalid.each do |nameservers|
      context "when ::nameservers #{nameservers}" do
        let :params do
          {
            nameservers: nameservers,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects an Array}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::dnssearchdomains valid' do
    dnssearchdomains = ['raft.com', 'openstack.raft.com', 'mesos.raft.com']
    context "when ::dnssearchdomains #{dnssearchdomains}" do
      let :params do
        {
          dnssearchdomains: dnssearchdomains,
        }
      end

      it {
        is_expected.to contain_concat_fragment('dhcp-conf-header').with(
          content: %r{option domain-search "#{dnssearchdomains.join('", "')}";},
        )
      }
      it { is_expected.to compile }
    end
  end

  context 'when ::dnssearchdomains invalid' do
    invalid = [123, 'string', true, { dnssearchdomains: ['raft.com', 'openstack.raft.com'] }]
    invalid.each do |dnssearchdomains|
      context "when ::dnssearchdomains #{dnssearchdomains}" do
        let :params do
          {
            dnssearchdomains: dnssearchdomains,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects an Array}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::ntpservers valid' do
    ntpservers = ['204.93.207.13', '1.us.pool.ntp.org', '2.us.pool.ntp.org']
    context "when ::ntpservers #{ntpservers}" do
      let :params do
        {
          ntpservers: ntpservers,
        }
      end

      it {
        is_expected.to contain_concat_fragment('dhcp-conf-ntp').with(
          content: %r{option ntp-servers #{ntpservers.join(", ")};},
        )
      }
      it { is_expected.to compile }
    end
  end

  context 'when ::ntpservers invalid' do
    invalid = [123, 'string', true, { ntpservers: ['1.us.pool.ntp.org', '204.93.207.13'] }]
    invalid.each do |ntpservers|
      context "when ::ntpservers #{ntpservers}" do
        let :params do
          {
            ntpservers: ntpservers,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects an Array}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::pools valid' do
    pools =
      {
        'raft.com' => {
          network: '192.168.0.0',
          mask:    '255.255.255.0',
          gateway: '192.168.0.1',
        },
        'waddle.com' => {
          network: '192.168.1.0',
          mask:    '255.255.255.0',
          gateway: '192.168.1.1',
        },
      }
    let :params do
      {
        pools: pools,
      }
    end

    pools.each do |key, value|
      it {
        is_expected.to contain_concat_fragment("dhcp_pool_#{key}").with(
          target: '/etc/dhcp/dhcpd.pools',
          content: %r{#{key} #{value[:network]} #{value[:mask]}},
        )
      }
    end
    it { is_expected.to compile }
  end

  context 'when ::pools invalid' do
    invalid = [123, 'string', true, { pool: ['192.168.0.0', '255.255.0.0', '193.168.1.1'] }]
    invalid.each do |pools|
      context "when ::pools #{pools}" do
        let :params do
          {
            pools: pools,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Hash}) }
        it { is_expected.not_to compile }
      end
    end
  end
end

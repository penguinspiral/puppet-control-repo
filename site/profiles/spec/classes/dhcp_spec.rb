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
    it {
      is_expected.to contain_concat_fragment('dhcp-conf-ddns').with(
        content: %r{^ddns-update-style none;$},
      )
    }
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

  context 'when ::dnsupdatekey valid' do
    valid = ['/etc/bind/rndc-key.key', '/etc/bind/raft.com.key']
    valid.each do |dnsupdatekey|
      context "when ::dnsupdatekey #{dnsupdatekey}" do
        let :params do
          {
            dnsupdatekey: dnsupdatekey,
          }
        end

        it {
          is_expected.to contain_concat_fragment('dhcp-conf-ddns').with(
            content: %r{ddns-updates on;.*include "#{dnsupdatekey}";}m,
          )
        }
        it { is_expected.to compile }
      end
    end
    context 'when ::dnsupdatekey undef' do
      let :params do
        {
          dnsupdatekey: :undef,
        }
      end

      it {
        is_expected.to contain_concat_fragment('dhcp-conf-ddns').with(
          content: %r{^ddns-update-style none;$},
        )
      }
      it { is_expected.to compile }
    end
  end

  context 'when ::dnsupdatekyey invalid' do
    invalid = [123, 'rndc-key', true, ['/etc/bind/rndc-key.key', '/etc/bind/raft.com.key']]
    invalid.each do |dnsupdatekey|
      context "when ::dnsupdatekey #{dnsupdatekey}" do
        let :params do
          {
            dnsupdatekey: dnsupdatekey,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Stdlib::Absolutepath}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::dnskeyname valid' do
    dependency_params =
      {
        dnsupdatekey: '/etc/bind/rndc.key',
        dnsdomain:    ['raft.com'],
      }
    valid = ['rndc-key', 'raft.com', 'waddle.com']
    valid.each do |dnskeyname|
      context "when ::dnskeyname #{dnskeyname}" do
        let :params do
          dependency_params.merge(
            dnskeyname: dnskeyname,
          )
        end

        it {
          is_expected.to contain_concat_fragment('dhcp-conf-ddns').with(
            content: %r{\nzone #{params[:dnsdomain].first}\. \{\n.*key #{dnskeyname};}m,
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::dnskeyname invalid' do
    invalid = [123, true, ['rndc-key', 'raft-key'], { key: 'rndc-key' }]
    invalid.each do |dnskeyname|
      context "when ::dnskeyname #{dnskeyname}" do
        let :params do
          {
            dnskeyname: dnskeyname,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a String}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::ddns_client_updates valid' do
    dependency_params =
      {
        dnsupdatekey: '/etc/bind/rndc.key',
      }
    valid = ['allow', 'deny']
    valid.each do |ddns_client_updates|
      context "when ::ddns_client_updates #{ddns_client_updates}" do
        let :params do
          dependency_params.merge(
            ddns_client_updates: ddns_client_updates,
          )
        end

        it {
          is_expected.to contain_concat_fragment('dhcp-conf-ddns').with(
            content: %r{\n#{ddns_client_updates} client-updates;$}m,
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::ddns_client_updates invalid' do
    invalid = [123, true, 'ignore', ['deny', 'allow']]
    invalid.each do |ddns_client_updates|
      context "when ::ddns_client_updates #{ddns_client_updates}" do
        let :params do
          {
            ddns_client_updates: ddns_client_updates,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Enum\['allow', 'deny'\]}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::ddns_update_style valid' do
    dependency_params =
      {
        dnsupdatekey: '/etc/bind/rndc.key',
      }
    valid = ['ad-hoc', 'interim', 'standard', 'none']
    valid.each do |ddns_update_style|
      context "when ::ddns_update_style #{ddns_update_style}" do
        let :params do
          dependency_params.merge(
            ddns_update_style: ddns_update_style,
          )
        end

        it {
          is_expected.to contain_concat_fragment('dhcp-conf-ddns').with(
            content: %r{\nddns-update-style #{ddns_update_style};$}m,
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::ddns_update_style invalid' do
    invalid = [123, true, 'full', ['standard', 'adhoc']]
    invalid.each do |ddns_update_style|
      context "when ::ddns_update_style #{ddns_update_style}" do
        let :params do
          {
            ddns_update_style: ddns_update_style,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Enum\['ad-hoc', 'interim', 'none', 'standard'\]}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::ddns_update_static valid' do
    dependency_params =
      {
        dnsupdatekey: '/etc/bind/rndc.key',
      }
    valid = ['on', 'off']
    valid.each do |ddns_update_static|
      context "when ::ddns_update_static #{ddns_update_static}" do
        let :params do
          dependency_params.merge(
            ddns_update_static: ddns_update_static,
          )
        end

        it {
          is_expected.to contain_concat_fragment('dhcp-conf-ddns').with(
            content: %r{\nupdate-static-leases #{ddns_update_static};$}m,
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::ddns_update_static invalid' do
    invalid = [123, false, 'full', ['on', 'off']]
    invalid.each do |ddns_update_static|
      context "when ::ddns_update_static #{ddns_update_static}" do
        let :params do
          {
            ddns_update_static: ddns_update_static,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Enum\['off', 'on'\]}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::ddns_update_optimize valid' do
    dependency_params =
      {
        dnsupdatekey: '/etc/bind/rndc.key',
      }
    valid = ['on', 'off']
    valid.each do |ddns_update_optimize|
      context "when ::ddns_update_optimize #{ddns_update_optimize}" do
        let :params do
          dependency_params.merge(
            ddns_update_optimize: ddns_update_optimize,
          )
        end

        it {
          is_expected.to contain_concat_fragment('dhcp-conf-ddns').with(
            content: %r{\nupdate-optimization #{ddns_update_optimize};$}m,
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::ddns_update_optimize invalid' do
    invalid = [123, false, 'full', ['on', 'off']]
    invalid.each do |ddns_update_optimize|
      context "when ::ddns_update_optimize #{ddns_update_optimize}" do
        let :params do
          {
            ddns_update_optimize: ddns_update_optimize,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Enum\['off', 'on'\]}) }
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

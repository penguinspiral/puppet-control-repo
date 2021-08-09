require 'spec_helper'

describe 'profiles::bootstrap::node::server', type: :class do
  context 'when default' do
    puppetserver_service_default = {
      owner: 'root',
      group: 'root',
    }
    puppetserver_service_files = [
      {
        path:   '/etc/systemd/system/multi-user.target.wants/puppetserver.service',
        ensure: 'link',
        target: '/lib/systemd/system/puppetserver.service',
      },
      {
        path:   '/etc/systemd/system/puppetserver.service.d',
        ensure: 'directory',
      },
      {
        path:    '/etc/systemd/system/puppetserver.service.d/override.conf',
        ensure:  'file',
        content: "[Unit]\nBefore=puppet.service",
      },
    ]
    puppetserver_ini_default = {
      ensure:            'present',
      path:              '/etc/puppetlabs/puppet/puppet.conf',
      key_val_separator: '=',
    }
    puppetserver_ini_settings = [
      {
        name:    'r10k_prerun_command',
        section: 'main',
        setting: 'prerun_command',
        value:   '/usr/bin/r10k deploy environment --verbose --puppetfile --config /etc/puppetlabs/r10k/r10k.yaml',
      },
      {
        name:    'puppetserver_dns_alt_names',
        section: 'server',
        setting: 'dns_alt_names',
        value:   'localhost',
      },
    ]
    it { is_expected.to have_file_resource_count(puppetserver_service_files.length) }
    it { is_expected.to have_hocon_setting_resource_count(1) }
    it { is_expected.to have_ini_setting_resource_count(puppetserver_ini_settings.length) }
    puppetserver_service_files.each do |file|
      it {
        is_expected.to contain_file(file[:path]).with(
          file.merge(puppetserver_service_default),
        )
      }
    end
    puppetserver_ini_settings.each do |ini_setting|
      it {
        is_expected.to contain_ini_setting(ini_setting[:name]).with(
          ini_setting.merge(puppetserver_ini_default),
        )
      }
    end
    it {
      is_expected.to contain_hocon_setting('puppetserver_webserver_host').with(
        ensure:  'present',
        path:    '/etc/puppetlabs/puppetserver/conf.d/webserver.conf',
        setting: 'webserver.ssl-host',
        value:   'localhost',
      )
    }
    it { is_expected.to compile }
  end

  context 'when ::puppet_config valid' do
    valid =
      [
        '/opt/puppetlabs/puppet.conf',
        '/etc/puppet/puppet.conf',
      ]
    valid.each do |puppet_config|
      context "when ::puppet_config #{puppet_config}" do
        let :params do
          {
            puppet_config: puppet_config,
          }
        end

        it {
          is_expected.to contain_ini_setting('r10k_prerun_command').with(
            path: puppet_config,
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::puppet_config invalid' do
    invalid = [123, 'string', [1, 2, 3], true, 'relative/path/puppet.conf']
    invalid.each do |puppet_config|
      context "when ::puppet_config #{puppet_config}" do
        let :params do
          {
            puppet_config: puppet_config,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Stdlib::Absolutepath}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::puppetserver_web_config valid' do
    valid =
      [
        '/opt/puppetlabs/puppetserver/webserver.conf',
        '/etc/puppet/server.conf',
      ]
    valid.each do |puppetserver_web_config|
      context "when ::puppetserver_web_config #{puppetserver_web_config}" do
        let :params do
          {
            puppetserver_web_config: puppetserver_web_config,
          }
        end

        it {
          is_expected.to contain_hocon_setting('puppetserver_webserver_host').with(
            path: puppetserver_web_config,
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::puppetserver_web_config invalid' do
    invalid = [123, 'string', [1, 2, 3], true, 'relative/path/webserver.conf']
    invalid.each do |puppetserver_web_config|
      context "when ::puppetserver_web_config #{puppetserver_web_config}" do
        let :params do
          {
            puppetserver_web_config: puppetserver_web_config,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Stdlib::Absolutepath}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::r10k_binary valid' do
    valid =
      [
        '/bin/r10k',
        '/usr/local/bin/r10k',
        '/home/debian/bin/r10k',
      ]
    valid.each do |r10k_binary|
      context "when ::r10k_binary #{r10k_binary}" do
        let :params do
          {
            r10k_binary: r10k_binary,
          }
        end

        it {
          is_expected.to contain_ini_setting('r10k_prerun_command').with(
            value: %r{^#{r10k_binary}},
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::r10k_binary invalid' do
    invalid = [123, 'string', [1, 2, 3], true, 'relative/path/r10k']
    invalid.each do |r10k_binary|
      context "when ::r10k_binary #{r10k_binary}" do
        let :params do
          {
            r10k_binary: r10k_binary,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Stdlib::Absolutepath}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::r10k_config valid' do
    valid =
      [
        '/etc/puppet/r10k/r10k.yaml',
        '/opt/puppetlabs/r10k/r10k.yaml',
      ]
    valid.each do |r10k_config|
      context "when ::r10k_config #{r10k_config}" do
        let :params do
          {
            r10k_config: r10k_config,
          }
        end

        it {
          is_expected.to contain_ini_setting('r10k_prerun_command').with(
            value: %r{#{r10k_config}},
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::r10k_config invalid' do
    invalid = [123, 'string', [1, 2, 3], true, 'relative/path/r10k.yaml']
    invalid.each do |r10k_config|
      context "when ::r10k_config #{r10k_config}" do
        let :params do
          {
            r10k_config: r10k_config,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Stdlib::Absolutepath}) }
        it { is_expected.not_to compile }
      end
    end
  end
end

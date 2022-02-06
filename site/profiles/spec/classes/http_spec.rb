require 'spec_helper'

describe 'profiles::http', type: :class do
  context 'when default' do
    apache_module_classes =
      [
        'apache',
        'apache::vhosts',
      ]
    apache_purge_dirs =
      [
        '/etc/apache2/mods-enabled',
        '/etc/apache2/sites-available',
        '/etc/apache2/sites-enabled',
      ]
    apache_default_vhosts =
      [
        'default',
        'default-ssl',
      ]
    apache_module_classes.each do |module_class|
      it {
        is_expected.to contain_class(module_class)
      }
    end
    it {
      is_expected.to contain_package('httpd').with(
        name:   'apache2',
        ensure: 'installed',
      )
    }
    it {
      is_expected.to contain_service('httpd').with(
        name:   'apache2',
        enable: false,
        ensure: 'stopped',
      )
    }
    apache_purge_dirs.each do |dir|
      it {
        is_expected.to contain_file(dir).with(
          path:  dir,
          purge: true,
        )
      }
    end
    apache_default_vhosts.each do |vhost|
      it {
        is_expected.to contain_apache__vhost(vhost).with(
          ensure: 'absent',
        )
      }
    end
    # Root docroot directory lockdown (deny)
    it {
      is_expected.to contain_file('/etc/apache2/apache2.conf').with(
        content: %r{<Directory />.*Require all denied.*</Directory>}m,
      )
    }
    it { is_expected.to compile }
  end

  context 'when ::service_enable valid' do
    valid = [true, false]
    valid.each do |service_enable|
      context "when ::service_enable #{service_enable}" do
        let :params do
          {
            service_enable: service_enable,
          }
        end

        it { is_expected.to contain_service('httpd').with('enable' => service_enable) }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::service_enable invalid' do
    invalid = ['enabled', 123, [true], { service: 'enabled' }]
    invalid.each do |service_enable|
      context "when ::service_enable #{service_enable}" do
        let :params do
          {
            service_enable: service_enable,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Boolean}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::service_ensure valid' do
    valid = ['running', 'stopped' ]
    valid.each do |service_ensure|
      context "when ::service_ensure #{service_ensure}" do
        let :params do
          {
            service_ensure: service_ensure,
          }
        end

        it { is_expected.to contain_service('httpd').with('ensure' => service_ensure) }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::service_ensure invalid' do
    invalid = ['disable', 123, true, { service: 'running' }]
    invalid.each do |service_ensure|
      context "when ::service_ensure #{service_ensure}" do
        let :params do
          {
            service_ensure: service_ensure,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Stdlib::Ensure::Service}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::default_vhost valid' do
    valid = { 'present' => true, 'absent' => false }
    valid.each do |default_vhost_key, default_vhost_value|
      context "when ::default_vhost #{default_vhost_value}" do
        let :params do
          {
            default_vhost: default_vhost_value,
          }
        end

        it {
          is_expected.to contain_apache__vhost('default').with(
            'ensure':  default_vhost_key,
            'port':    80,
            'docroot': '/var/www/html',
            'ssl':     false,
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::default_vhost invalid' do
    invalid = [123, 'true', ['none'], { vhost: 'secure' }]
    invalid.each do |default_vhost|
      context "when ::default_vhost #{default_vhost}" do
        let :params do
          {
            default_vhost: default_vhost,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Boolean}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::default_ssl_vhost valid' do
    valid = { 'present' => true, 'absent' => false }
    valid.each do |default_ssl_vhost_key, default_ssl_vhost_value|
      context "when ::default_ssl_vhost #{default_ssl_vhost_value}" do
        let :params do
          {
            default_ssl_vhost: default_ssl_vhost_value,
          }
        end

        it {
          is_expected.to contain_apache__vhost('default-ssl').with(
            'ensure':  default_ssl_vhost_key,
            'port':    443,
            'docroot': '/var/www/html',
            'ssl':     true,
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::default_ssl_vhost invalid' do
    invalid = [123, 'false', ['TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'], { default_vhost: 'insecure' }]
    invalid.each do |default_ssl_vhost|
      context "when ::default_ssl_vhost #{default_ssl_vhost}" do
        let :params do
          {
            default_ssl_vhost: default_ssl_vhost,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Boolean}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::root_directory_secured valid' do
    context 'when ::root_directory_secured true' do
      let :params do
        {
          root_directory_secured: true,
        }
      end

      it {
        is_expected.to contain_file('/etc/apache2/apache2.conf').with(
          content: %r{<Directory />.*Require all denied.*</Directory>}m,
        )
      }
      it { is_expected.to compile }
    end
    context 'when ::root_directory_secured false' do
      let :params do
        {
          root_directory_secured: false,
        }
      end

      it {
        is_expected.to contain_file('/etc/apache2/apache2.conf').without(
          content: %r{<Directory />.*Require all denied.*</Directory>}m,
        )
      }
      it { is_expected.to compile }
    end
  end

  context 'when ::vhosts valid' do
    vhosts =
      {
        'seed.raft.com' =>
          {
            ip:          '192.168.0.2',
            port:        8080,
            docroot:     '/var/www/html',
            directories:
              {
                path:    '/var/www/html',
                options: ['Indexes'],
              },
          },
        'vhost.raft.com' =>
          {
            ip:      '10.0.0.10',
            port:    433,
            docroot: '/mnt/data',
            directories:
              {
                path:    '/mnt/data',
                options: ['FollowSymLinks', 'MultiViews'],
              },
          },
      }
    context "when ::vhosts #{vhosts}" do
      let :params do
        {
          vhosts: vhosts,
        }
      end

      vhosts.each do |key, value|
        it { is_expected.to contain_apache__vhost(key) }
        it {
          is_expected.to contain_concat_file("25-#{key}.conf").with(
            path:    "/etc/apache2/sites-available/25-#{key}.conf",
            replace: true,
            owner:   'root',
            group:   'root',
            mode:    '0644',
          )
        }
        it {
          is_expected.to contain_concat_fragment("#{key}-apache-header").with(
            content: %r{<VirtualHost #{value[:ip]}:#{value[:port]}>\n  ServerName #{key}$}m,
          )
        }
        it {
          is_expected.to contain_concat_fragment("#{key}-docroot").with(
            content: %r{DocumentRoot \"#{value[:docroot]}\"\n$}m,
          )
        }
        it {
          is_expected.to contain_concat_fragment("#{key}-directories").with(
            content: %r{<Directory \"#{value[:directories][:path]}\">\n    Options #{value[:directories][:options].join(' ')}}m,
          )
        }
        it {
          is_expected.to contain_file("25-#{key}.conf symlink").with(
            path:     "/etc/apache2/sites-enabled/25-#{key}.conf",
            ensure:   'link',
          ).that_requires("Concat_file[25-#{key}.conf]")
        }
      end
      it { is_expected.to compile }
    end
  end

  context 'when ::vhosts invalid' do
    invalid = [123, true, ['seed.raft.com']]
    invalid.each do |vhosts|
      context "when ::vhosts #{vhosts}" do
        let :params do
          {
            vhosts: vhosts,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Hash}) }
        it { is_expected.not_to compile }
      end
    end
  end
end

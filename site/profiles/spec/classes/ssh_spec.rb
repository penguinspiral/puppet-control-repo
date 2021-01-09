require 'spec_helper'

describe 'profiles::ssh', type: :class do
  context 'when default' do
    openssh_packages =
      [
        'openssh-client',
        'openssh-server',
      ]
    openssh_config =
      {
        # Class defaults do not manage global SSH client configuration
        'ssh_config' => {
          path: '/etc/ssh/ssh_config.fake',
          mode: '0644',
        },
        'sshd_config' => {
          path: '/etc/ssh/sshd_config',
          mode: '0600',
        },
        'ssh_known_hosts' => {
          path: '/etc/ssh/ssh_known_hosts',
          mode: '0644',
        },
      }
    openssh_sshd_config =
      {
        'PermitRootLogin'        => 'no',
        'PasswordAuthentication' => 'no',
        'PubkeyAuthentication'   => 'yes',
      }
    it { is_expected.to contain_class('ssh') }
    it { is_expected.to have_package_resource_count(openssh_packages.length) }
    openssh_packages.each do |package|
      it { is_expected.to contain_package(package).with('ensure' => 'installed') }
    end
    it { is_expected.to have_file_resource_count(openssh_config.length) }
    openssh_config.each do |file, value|
      it {
        is_expected.to contain_file(file).with(
          path:   value[:path],
          ensure: 'file',
          owner:  'root',
          group:  'root',
          mode:   value[:mode],
        )
      }
    end
    openssh_sshd_config.each do |config, value|
      it {
        is_expected.to contain_file('sshd_config').with('content' => %r{\n^#{config} #{value}}m)
      }
    end
    # Default SSH public key distribution should be limited to just the 'debian' user
    it { is_expected.to have_ssh_authorized_key_resource_count(1) }
    it {
      is_expected.to contain_ssh_authorized_key('raft.com').with(
        user: 'debian',
        type: 'ssh-rsa',
        # Ref: https://gist.github.com/paranoiq/1932126
        key:  %r{^AAAA[0-9A-Za-z+/]+[=]{0,3}},
      )
    }
    it { is_expected.to contain_resources('sshkey').with('purge' => 'true') }
    it { is_expected.to contain_service('sshd_service').with('ensure' => 'running') }
    it { is_expected.to compile }
  end

  context 'when ::service_ensure valid' do
    valid = ['running', 'stopped']
    valid.each do |service_ensure|
      context "when ::service_ensure #{service_ensure}" do
        let :params do
          {
            service_ensure: service_ensure,
          }
        end

        it { is_expected.to contain_service('sshd_service').with('ensure' => service_ensure) }
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

        it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Stdlib::Ensure::Service}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::manage_sshd_config valid' do
    context 'when ::manage_sshd_config true' do
      let :params do
        {
          manage_sshd_config: true,
        }
      end

      it {
        is_expected.to contain_file('sshd_config').with(
          path: '/etc/ssh/sshd_config',
          mode: '0600',
        )
      }
      it { is_expected.to compile }
    end

    context 'when ::manage_sshd_config false' do
      let :params do
        {
          manage_sshd_config: false,
        }
      end

      it { is_expected.not_to contain_file('sshd_config').with('path' => '/etc/ssh/sshd_config') }
      it {
        is_expected.to contain_file('sshd_config').with(
          path: '/etc/ssh/sshd_config.fake',
          mode: '0600',
        )
      }
      it { is_expected.to compile }
    end
  end

  context 'when ::manage_sshd_config invalid' do
    invalid = [123, 'string', [1, 2, 3], { ssh: 'server' }]
    invalid.each do |manage_sshd_config|
      context "when ::manage_sshd_config #{manage_sshd_config}" do
        let :params do
          {
            manage_sshd_config: manage_sshd_config,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Boolean}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::manage_ssh_config valid' do
    context 'when ::manage_ssh_config true' do
      let :params do
        {
          manage_ssh_config: true,
        }
      end

      it {
        is_expected.to contain_file('ssh_config').with(
          path: '/etc/ssh/ssh_config',
          mode: '0644',
        )
      }
      it { is_expected.to compile }
    end

    context 'when ::manage_ssh_config false' do
      let :params do
        {
          manage_ssh_config: false,
        }
      end

      it { is_expected.not_to contain_file('ssh_config').with('path' => '/etc/ssh/ssh_config') }
      it {
        is_expected.to contain_file('ssh_config').with(
          path: '/etc/ssh/ssh_config.fake',
          mode: '0644',
        )
      }
      it { is_expected.to compile }
    end
  end

  context 'when ::manage_ssh_config invalid' do
    invalid = [123, 'string', [1, 2, 3], { ssh: 'client' }]
    invalid.each do |manage_ssh_config|
      context "when ::manage_ssh_config #{manage_ssh_config}" do
        let :params do
          {
            manage_ssh_config: manage_ssh_config,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Boolean}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::sshd_config_path valid' do
    valid = ['/etc/ssh/sshd_config', '/etc/ssh/sshd/config']
    valid.each do |sshd_config_path|
      context "when ::sshd_config_path #{sshd_config_path}" do
        let :params do
          {
            manage_sshd_config: true,
            sshd_config_path:   sshd_config_path,
          }
        end

        it {
          is_expected.to contain_file('sshd_config').with(
            path: sshd_config_path,
            mode: '0600',
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::sshd_config_path invalid' do
    invalid = [123, 'sshd_config', [1, 2, 3], { sshd_config: 'server' }]
    invalid.each do |sshd_config_path|
      context "when ::sshd_config_path #{sshd_config_path}" do
        let :params do
          {
            manage_sshd_config: true,
            sshd_config_path:   sshd_config_path,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Stdlib::Absolutepath}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::ssh_config_path valid' do
    valid = ['/etc/ssh/ssh_config', '/etc/ssh/ssh/config']
    valid.each do |ssh_config_path|
      context "when ::ssh_config_path #{ssh_config_path}" do
        let :params do
          {
            manage_ssh_config: true,
            ssh_config_path:   ssh_config_path,
          }
        end

        it {
          is_expected.to contain_file('ssh_config').with(
            path: ssh_config_path,
            mode: '0644',
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::ssh_config_path invalid' do
    invalid = [123, 'ssh_config', [1, 2, 3], { ssh_config: 'server' }]
    invalid.each do |ssh_config_path|
      context "when ::ssh_config_path #{ssh_config_path}" do
        let :params do
          {
            manage_ssh_config: true,
            ssh_config_path:   ssh_config_path,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Stdlib::Absolutepath}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::permit_root_login valid' do
    valid = ['yes', 'no', 'without-password', 'forced-commands-only']
    valid.each do |permit_root_login|
      context "when ::permit_root_login #{permit_root_login}" do
        let :params do
          {
            permit_root_login: permit_root_login,
          }
        end

        it { is_expected.to contain_file('sshd_config').with('content' => %r{\n^PermitRootLogin #{permit_root_login}}m) }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::permit_root_login invalid' do
    invalid = [123, 'permit_root_login', [1, 2, 3], { root_login: 'without-password' }]
    invalid.each do |permit_root_login|
      context "when ::permit_root_login #{permit_root_login}" do
        let :params do
          {
            permit_root_login: permit_root_login,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Enum\['forced-commands-only', 'no', 'without-password', 'yes'\]}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::sshd_password_authentication valid' do
    valid = ['yes', 'no']
    valid.each do |sshd_password_authentication|
      context "when ::sshd_password_authentication #{sshd_password_authentication}" do
        let :params do
          {
            sshd_password_authentication: sshd_password_authentication,
          }
        end

        it { is_expected.to contain_file('sshd_config').with('content' => %r{\n^PasswordAuthentication #{sshd_password_authentication}}m) }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::sshd_password_authentication invalid' do
    invalid = [123, 'password_authentication', [1, 2, 3], { password_authentication: 'enable' }]
    invalid.each do |sshd_password_authentication|
      context "when ::sshd_password_authentication #{sshd_password_authentication}" do
        let :params do
          {
            sshd_password_authentication: sshd_password_authentication,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Enum\['no', 'yes'\]}) }
        it { is_expected.not_to compile }
      end
    end
    # Inaccessible SSH server scenario
    context "when ::sshd_password_authentication 'no' and ::keys is empty" do
      let :params do
        {
          sshd_password_authentication: 'no',
          keys:                         {},
        }
      end

      it { is_expected.to raise_error(Puppet::Error, %r{No SSH public key referenced and password authentication is disabled!}) }
      it { is_expected.not_to compile }
    end
  end

  context 'when ::sshd_pubkeyauthentication valid' do
    valid = ['yes', 'no']
    valid.each do |sshd_pubkeyauthentication|
      context "when ::sshd_pubkeyauthentication #{sshd_pubkeyauthentication}" do
        let :params do
          {
            sshd_pubkeyauthentication: sshd_pubkeyauthentication,
          }
        end

        it { is_expected.to contain_file('sshd_config').with('content' => %r{\n^PubkeyAuthentication #{sshd_pubkeyauthentication}}m) }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::sshd_pubkeyauthentication invalid' do
    invalid = [123, 'pubkey_authentication', [1, 2, 3], { pubkey_authentication: 'enable' }]
    invalid.each do |sshd_pubkeyauthentication|
      context "when ::sshd_pubkeyauthentication #{sshd_pubkeyauthentication}" do
        let :params do
          {
            sshd_pubkeyauthentication: sshd_pubkeyauthentication,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Enum\['no', 'yes'\]}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::keys valid' do
    keys =
      {
        'raft.com' =>
          {
            user: 'debian',
            type: 'ssh-rsa',
            key:  'AAAAB3NzaC1yc2E=PUBKEY',
          },
        'openstack.raft.com' =>
          {
            user: 'openstack',
            type: 'ecdsa-sha2-nistp256',
            key:  'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTY=PUBKEY',
          },
      }
    context "when ::keys #{keys}" do
      let :params do
        {
          keys: keys,
        }
      end

      keys.each do |key, value|
        it {
          is_expected.to contain_ssh_authorized_key(key).with(
            user: value[:user],
            type: value[:type],
            key:  value[:key],
          )
        }
      end
      it { is_expected.to compile }
    end
  end

  context 'when ::keys invalid' do
    invalid = [123, 'enable', false, ['debian', 'ssh-rsa', 'AAAAB3NzaC1yc2E=PUBKEY']]
    invalid.each do |keys|
      context "when ::keys #{keys}" do
        let :params do
          {
            keys: keys,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Hash}) }
        it { is_expected.not_to compile }
      end
    end
  end
end

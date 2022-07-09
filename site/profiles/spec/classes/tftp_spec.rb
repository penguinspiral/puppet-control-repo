require 'spec_helper'

describe 'profiles::tftp' do
  context 'when default' do
    tftpd_files =
      [
        '/etc/default/tftpd-hpa',
      ]
    it { is_expected.to contain_class('tftp') }
    # TFTP Package & Service resource management not exposed via 'puppetlabs-tftp' module
    it { is_expected.to contain_package('tftpd-hpa').with('ensure' => 'present') }
    it { is_expected.to contain_service('tftpd-hpa').with('ensure' => 'running') }
    it { is_expected.to have_file_resource_count(tftpd_files.length) }
    it {
      is_expected.to contain_file('/etc/default/tftpd-hpa').with(
        ensure:  'file',
        owner:   'root',
        group:   'root',
        mode:    '0644',
        notify:  'Service[tftpd-hpa]',
        content: %r{.*TFTP_USERNAME=\"tftp\"\nTFTP_DIRECTORY=\"\"\nTFTP_ADDRESS=\"localhost:69\"\nTFTP_OPTIONS=\"\"$}m,
      )
    }
    # xinetd explicitly disabled
    it { is_expected.not_to contain_class('xinetd') }
    it { is_expected.not_to contain_xinetd__service('tftp') }
  end

  context 'when ::address valid' do
    # Stdlib::Host
    valid = ['localhost', '0.0.0.0', '192.168.0.1', 'seed.raft.com', 'seed']
    valid.each do |address|
      context "when ::address #{address}" do
        let :params do
          {
            address: address,
          }
        end

        it { is_expected.to contain_file('/etc/default/tftpd-hpa').with(content: %r{.*TFTP_ADDRESS=\"#{address}:69\".*}m) }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::address invalid' do
    invalid = [123, ['0.0.0.0', '192.168.0.1'], true]
    invalid.each do |address|
      context "when ::address #{address}" do
        let :params do
          {
            address: address,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Stdlib::Host}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::port valid' do
    # Stdlib::Port
    valid = [69, 6969, 65_535]
    valid.each do |port|
      context "when ::port #{port}" do
        let :params do
          {
            port: port,
          }
        end

        it { is_expected.to contain_file('/etc/default/tftpd-hpa').with(content: %r{.*TFTP_ADDRESS=\"localhost:#{port}\".*}m) }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::port invalid' do
    invalid = ['69', 1.23, [69, 6969], true]
    invalid.each do |port|
      context "when ::port #{port}" do
        let :params do
          {
            port: port,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Stdlib::Port}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::username valid' do
    valid = ['tftp', 'grindon', 'root']
    valid.each do |username|
      context "when ::username #{username}" do
        let :params do
          {
            username: username,
          }
        end

        it { is_expected.to contain_file('/etc/default/tftpd-hpa').with(content: %r{.*TFTP_USERNAME=\"#{username}\".*}m) }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::username invalid' do
    invalid = [123, true, ['tftp', 'root']]
    invalid.each do |username|
      context "when ::username #{username}" do
        let :params do
          {
            username: username,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a String}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::managed_dirs valid' do
    valid = [['/srv/tftp'], ['/srv/tftp', '/mnt/export']]
    valid.each do |managed_dirs|
      context "when ::managed_dirs #{managed_dirs}" do
        let :params do
          {
            managed_dirs: managed_dirs,
          }
        end

        managed_dirs.each do |managed_dir|
          it {
            is_expected.to contain_file(managed_dir).with(
              ensure: 'directory',
              mode:   '0755',
              owner:  'root',
              group:  'nogroup',
            )
          }
        end
        it { is_expected.to contain_file('/etc/default/tftpd-hpa').with(content: %r{.*TFTP_DIRECTORY=\"#{managed_dirs.join(' ')}\".*}m) }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::managed_dirs invalid' do
    invalid = ['/srv/tftp', 'home', 123, false]
    invalid_array = [['root', 'home'], [123], [true]]
    invalid.each do |managed_dirs|
      context "when ::managed_dirs #{managed_dirs}" do
        let :params do
          {
            managed_dirs: managed_dirs,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects an Array }) }
        it { is_expected.not_to compile }
      end
    end
    invalid_array.each do |managed_dirs|
      context "when ::managed_dirs #{managed_dirs}" do
        let :params do
          {
            managed_dirs: managed_dirs,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Stdlib::Absolutepath}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::options valid' do
    valid = [['--secure'], ['--foreground', '--verbose', '--verbosity 5']]
    valid.each do |options|
      context "when ::options #{options}" do
        let :params do
          {
            options: options,
          }
        end

        it { is_expected.to contain_file('/etc/default/tftpd-hpa').with(content: %r{.*TFTP_OPTIONS=\"#{options.join(' ')}\"$}m) }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::options invalid' do
    invalid = ['--secure', 'enabled', 123, true]
    invalid_array = [[123], [{ flag: '--secure' }], [true, {}]]
    invalid.each do |options|
      context "when ::options #{options}" do
        let :params do
          {
            options: options,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects an Array }) }
        it { is_expected.not_to compile }
      end
    end
    invalid_array.each do |options|
      context "when ::options #{options}" do
        let :params do
          {
            options: options,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a String}) }
        it { is_expected.not_to compile }
      end
    end
  end
end

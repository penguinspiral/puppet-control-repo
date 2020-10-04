require 'spec_helper'

describe 'profiles::bootstrap::node::master', type: :class do
  puppet_master_service_default = {
    owner: 'root',
    group: 'root',
  }

  puppet_master_service_files = [
    {
      path:   '/etc/systemd/system/multi-user.target.wants/puppet-master.service',
      ensure: 'link',
      target: '/lib/systemd/system/puppet-master.service',
    },
    {
      path:   '/etc/systemd/system/puppet-master.service.d',
      ensure: 'directory',
    },
    {
      path:    '/etc/systemd/system/puppet-master.service.d/override.conf',
      content: "[Unit]\nBefore=puppet.service",
    },
  ]

  puppet_master_conf_default = {
    ensure:            'present',
    path:              '/etc/puppet/puppet.conf',
    key_val_separator: '=',
  }

  puppet_master_conf_settings = [
    {
      name:    'r10k_prerun',
      section: 'main',
      setting: 'prerun_command',
      value:   '/usr/bin/r10k deploy environment --verbose --puppetfile --config /etc/puppet/r10k/r10k.yaml',
    },
    {
      name:    'puppet_master_dns_cert',
      section: 'master',
      setting: 'dns_alt_names',
      value:   'localhost',
    },
    {
      name:    'puppet_master_localhost',
      section: 'master',
      setting: 'bindaddress',
      value:   '127.0.0.1',
    },
  ]

  context 'when default' do
    puppet_master_service_files.each do |file|
      it { is_expected.to contain_file(file[:path]).with(file.merge(puppet_master_service_default)) }
    end
    puppet_master_conf_settings.each do |setting|
      it { is_expected.to contain_ini_setting(setting[:name]).with(setting.merge(puppet_master_conf_default)) }
    end
    it { is_expected.to have_file_resource_count(3) }
    it { is_expected.to have_ini_setting_resource_count(3) }
    it { is_expected.to compile }
  end
end

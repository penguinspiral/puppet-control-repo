require 'spec_helper'

describe 'profiles::bootstrap::agent', type: :class do
  context 'when default' do
    facter_exec = {
      command: 'mkdir -p /etc/facter/facts.d',
      creates: '/etc/facter/facts.d',
    }
    facter_file_dir = {
      path:    facter_exec[:creates],
      ensure:  'directory',
      mode:    '0755',
      owner:   'root',
      group:   'root',
      require: 'Exec[mkdir_p-/etc/facter/facts.d]',
    }
    facter_concat_file = {
      path:  "#{facter_file_dir[:path]}/facts.txt",
      mode:  '0644',
      owner: 'root',
      group: 'root',
    }
    facter_concat_fragment = {
      name:    'fact_line_role',
      target:  'facts_file',
      content: 'role=seed',
    }

    puppet_agent_service_file = {
      path:   '/etc/systemd/system/multi-user.target.wants/puppet.service',
      ensure: 'link',
      owner:  'root',
      group:  'root',
      target: '/lib/systemd/system/puppet.service',
    }

    puppetserver_ini_setting = {
      name:              'puppetserver_host',
      ensure:            'present',
      path:              '/etc/puppetlabs/puppet/puppet.conf',
      key_val_separator: '=',
      section:           'main',
      setting:           'server',
      value:             'localhost',
    }

    it { is_expected.to contain_class('apt') }
    it {
      is_expected.to contain_exec('apt_update').with(
        command: '/usr/bin/apt-get update',
      )
    }

    it { is_expected.to have_facter__fact_resource_count(1) }
    it { is_expected.to contain_facter__fact('role').with({ value: 'seed' }) }
    it { is_expected.to contain_class('facter') }
    it { is_expected.to contain_exec('mkdir_p-/etc/facter/facts.d').with(facter_exec) }
    it { is_expected.to contain_file('facts_d_directory').with(facter_file_dir) }
    it { is_expected.to contain_concat('facts_file').with(facter_concat_file) }
    it { is_expected.to contain_concat__fragment('fact_line_role').with(facter_concat_fragment) }

    it { is_expected.to have_ini_setting_resource_count(1) }
    it { is_expected.to contain_file(puppet_agent_service_file[:path]).with(puppet_agent_service_file) }
    it { is_expected.to contain_ini_setting(puppetserver_ini_setting[:name]).with(puppetserver_ini_setting) }
    it { is_expected.to compile }
  end

  context 'when ::role valid' do
    valid = ['seed', 'vmm', 'webserver', 'database']
    valid.each do |role|
      context "when ::role #{role}" do
        let :params do
          {
            role: role,
          }
        end

        it { is_expected.to have_facter__fact_resource_count(1) }
        it {
          is_expected.to contain_facter__fact('role').with(
            value: role,
          )
        }
        it {
          is_expected.to contain_concat__fragment('fact_line_role').with(
            content: "role=#{role}",
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::role invalid' do
    invalid = [{ role: 'cache' }, ['vmm', 'NAS'], true, '']
    invalid.each do |role|
      context "when ::role #{role}" do
        let :params do
          {
            role: role,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a String}) }
        it { is_expected.not_to compile }
      end
    end
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
          is_expected.to contain_ini_setting('puppetserver_host').with(
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

  context 'when ::puppetserver valid' do
    valid = ['node', 'node.raft.com', 'node.subdomain.raft.com', '192.168.0.2']
    valid.each do |puppetserver|
      context "when ::puppetserver #{puppetserver}" do
        let :params do
          {
            puppetserver: puppetserver,
          }
        end

        it {
          is_expected.to contain_ini_setting('puppetserver_host').with(
            value: puppetserver,
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::puppetserver invalid' do
    invalid = [123, ['a', 'host', 'name'], { host: 'name' }, true]
    invalid.each do |puppetserver|
      context "when ::puppetserver #{puppetserver}" do
        let :params do
          {
            puppetserver: puppetserver,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Stdlib::Host}) }
        it { is_expected.not_to compile }
      end
    end
  end
end

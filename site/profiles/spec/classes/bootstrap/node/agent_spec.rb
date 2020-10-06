require 'spec_helper'

describe 'profiles::bootstrap::node::agent', type: :class do
  puppet_agent = {
    ensure: 'link',
    path:   '/etc/systemd/system/multi-user.target.wants/puppet.service',
    owner:  'root',
    group:  'root',
    target: '/lib/systemd/system/puppet.service',
  }

  puppet_conf = {
    ensure:            'present',
    name:              'puppet_server_host',
    path:              '/etc/puppet/puppet.conf',
    key_val_separator: '=',
    section:           'main',
    setting:           'server',
    value:             'localhost',
  }

  context 'when default' do
    it { is_expected.to contain_file(puppet_agent[:path]).with(puppet_agent) }
    it { is_expected.to contain_ini_setting(puppet_conf[:name]).with(puppet_conf) }
    it { is_expected.to compile }
  end

  context 'when ::puppet_server Sdlib::Host' do
    server = ['node', 'node.raft.com', 'node.subdomain.raft.com', '192.168.0.2']
    server.each do |host|
      context "when ::puppet_server #{host}" do
        let :params do
          {
            puppet_server: host,
          }
        end

        it { is_expected.to compile }
      end
    end
  end

  context 'when ::puppet_server invalid' do
    server = [123, ['a', 'host', 'name'], { host: 'name' }, true]
    server.each do |host|
      context "when ::puppet_server #{host}" do
        let :params do
          {
            puppet_server: host,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Stdlib::Host}) }
        it { is_expected.not_to compile }
      end
    end
  end
end

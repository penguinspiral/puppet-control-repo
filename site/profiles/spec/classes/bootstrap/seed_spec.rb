require 'spec_helper'

describe 'profiles::bootstrap::seed', type: :class do
  facter_bootstrap_conf = {
    ensure: 'file',
    path:   '/etc/facter/facts.d/bootstrap.yaml',
    mode:   '0600',
    content: %r{role: seed},
  }

  facter_dirs      = ['/etc/facter', '/etc/facter/facts.d/']
  facter_dirs_attr = {
    ensure: 'directory',
    mode:   '0755',
    owner:  'root',
    group:  'root',
  }

  context 'when default' do
    it { is_expected.to contain_class('apt') }
    it {
      is_expected.to contain_exec('apt_update').with(
        command: '/usr/bin/apt-get update',
      )
    }
    facter_dirs.each do |dir|
      it { is_expected.to contain_file(dir).with(facter_dirs_attr) }
    end
    it { is_expected.to contain_file(facter_bootstrap_conf[:path]).with(facter_bootstrap_conf) }
    it { is_expected.to compile }
  end
end

require 'spec_helper'

describe 'profiles::apt', type: :class do
  context 'when default' do
    sources_config =
      {
        'sources.list'   => false,
        'sources.list.d' => false,
      }
    preferences_config =
      {
        'preferences'    => false,
        'preferences.d'  => false,
      }
    apt_config =
      {
        'apt.conf.d'     => false,
      }
    it {
      is_expected.to contain_class('apt').with(
        purge_defaults: [*sources_config, *preferences_config, *apt_config].to_h,
      )
    }
    it { is_expected.to contain_class('apt::update') }
    it { is_expected.to have_exec_resource_count(1) }
    it {
      is_expected.to contain_exec('apt_update').with(
        command: '/usr/bin/apt-get update',
      )
    }
    it { is_expected.to compile }
  end

  context 'when ::purge all true' do
    purge =
      {
        'sources.list'   => true,
        'sources.list.d' => true,
        'preferences'    => true,
        'preferences.d'  => true,
        'apt.conf.d'     => true,
      }
    let :params do
      {
        purge: purge,
      }
    end

    it {
      is_expected.to contain_class('apt').with(
        purge: purge,
      )
    }
    it {
      is_expected.to contain_file('sources.list').with(
        path:    '/etc/apt/sources.list',
        ensure:  'file',
        content: %r{managed by puppet},
      )
    }
    it {
      is_expected.to contain_file('sources.list.d').with(
        path:   '/etc/apt/sources.list.d',
        ensure: 'directory',
        purge:  true,
        recurse: true,
      )
    }
    it {
      is_expected.to contain_file('preferences').with(
        path:   '/etc/apt/preferences',
        ensure: 'absent',
      )
    }
    it {
      is_expected.to contain_file('preferences.d').with(
        path:    '/etc/apt/preferences.d',
        ensure:  'directory',
        purge:   true,
        recurse: true,
      )
    }
    it {
      is_expected.to contain_file('apt.conf.d').with(
        path:    '/etc/apt/apt.conf.d',
        ensure:  'directory',
        purge:   true,
        recurse: true,
      )
    }
    it { is_expected.to compile }
  end

  context 'when ::purge invalid' do
    invalid = [123, 'string', [1, 2, 3], true]
    invalid.each do |purge|
      context "when ::purge #{purge}" do
        let :params do
          {
            purge: purge,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Hash}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::sources valid' do
    sources =
      {
        'debian_buster' => {
          comment:  'Official Debian Buster mirror',
          location: 'http://mirrors.kernel.org/debian',
          release:  'buster',
          repos:    'main contrib non-free',
        },
      }
    let :params do
      {
        sources: sources,
      }
    end

    it { is_expected.to contain_class('apt') }
    it {
      is_expected.to contain_apt__setting('list-debian_buster').with(
        ensure:        'present',
        notify_update: true,
      )
    }
    it {
      is_expected.to contain_file('/etc/apt/sources.list.d/debian_buster.list').with(
        path:    '/etc/apt/sources.list.d/debian_buster.list',
        ensure:  'present',
        content: %r{DO NOT EDIT},
      )
    }
    it { is_expected.to contain_class('apt::update') }
    it { is_expected.to have_exec_resource_count(1) }
    it {
      is_expected.to contain_exec('apt_update').with(
        command: '/usr/bin/apt-get update',
      )
    }
  end

  context 'when ::sources invalid' do
    invalid = [123, 'string', [1, 2, 3], true]
    invalid.each do |source|
      context "when ::sources #{source}" do
        let :params do
          {
            sources: source,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Hash}) }
        it { is_expected.not_to compile }
      end
    end
  end
end

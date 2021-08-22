require 'spec_helper'

describe 'profiles::dns', type: :class do
  context 'when default' do
    bind9_files =
      [
        '/etc/bind/rndc.key',
        '/etc/default/bind9',
        '/var/cache/bind/zones',
      ]
    bind9_concat_config =
      [
        '/etc/bind/zones.conf',
        '/etc/bind/named.conf',
        '/etc/bind/named.conf.options',
      ]
    it { is_expected.to contain_class('dns') }
    it { is_expected.to contain_package('bind9').with('ensure' => 'present') }
    it { is_expected.to contain_service('bind9').with('ensure' => 'stopped') }
    it { is_expected.to have_file_resource_count(bind9_files.length) }
    it { is_expected.to have_concat_file_resource_count(bind9_files.length) }
    # RNDC key is automatically created in 'dns::config' class
    it {
      is_expected.to contain_exec('create-rndc.key').with(
        command: %r{rndc-confgen.*/etc/bind/rndc.key},
        creates: '/etc/bind/rndc.key',
        before:  %r{^\["File\[/etc/bind/rndc.key\]"},
      )
    }
    it {
      is_expected.to contain_file('/etc/bind/rndc.key').with(
        owner: 'root',
        # Default: 'dns::params::group_manage'
        group: 'bind',
        mode:  '0640',
      )
    }
    it {
      is_expected.to contain_file('/etc/default/bind9').with(
        owner:   'root',
        group:   'root',
        content: %r{\nRESOLVCONF=no.*OPTIONS="-u bind"}m,
      )
    }
    it {
      is_expected.to contain_file('/var/cache/bind/zones').with(
        ensure: 'directory',
        owner:  'bind',
        group:  'bind',
        mode:   '0640',
      )
    }
    bind9_concat_config.each do |file|
      it {
        is_expected.to contain_concat_file(file).with(
          owner: 'root',
          group: 'bind',
          mode:  '0640',
        )
      }
    end
    it {
      is_expected.to contain_concat_file('/etc/bind/named.conf').with(
        validate_cmd: '/usr/sbin/named-checkconf %',
      )
    }
    it {
      is_expected.to contain_concat_file('/etc/bind/zones.conf').with(
        validate_cmd: '/usr/sbin/named-checkconf %',
      )
    }
    it {
      is_expected.to contain_concat_fragment('options.conf+10-main.dns').with(
        target:  '/etc/bind/named.conf.options',
        content: %r{\nrecursion no;.*allow-query { none; };.*allow-recursion { none; };.*}m,
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

        it { is_expected.to contain_service('bind9').with('ensure' => service_ensure) }
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

  context 'when ::config_check valid' do
    context 'when ::config_check true' do
      let :params do
        {
          config_check: true,
        }
      end

      it {
        is_expected.to contain_concat_file('/etc/bind/named.conf').with(
          validate_cmd: '/usr/sbin/named-checkconf %',
        )
      }
      it {
        is_expected.to contain_concat_file('/etc/bind/zones.conf').with(
          validate_cmd: '/usr/sbin/named-checkconf %',
        )
      }
      it { is_expected.to compile }
    end
    context 'when ::config_check false' do
      let :params do
        {
          config_check: false,
        }
      end

      it { is_expected.to contain_concat_file('/etc/bind/named.conf').without_validate_cmd }
      it { is_expected.to contain_concat_file('/etc/bind/zones.conf').without_validate_cmd }
      it { is_expected.to compile }
    end
  end

  context 'when ::config_check invalid' do
    invalid = [123, 'true', [true]]
    invalid.each do |config_check|
      context "when ::config_check #{config_check}" do
        let :params do
          {
            config_check: config_check,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Boolean}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::recursion valid' do
    valid = ['yes', 'no']
    valid.each do |recursion|
      context "when ::recursion #{recursion}" do
        let :params do
          {
            recursion: recursion,
          }
        end

        it {
          is_expected.to contain_concat_fragment('options.conf+10-main.dns').with(
            target:  '/etc/bind/named.conf.options',
            content: %r{\nrecursion #{recursion};.*},
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::recursion invalid' do
    invalid = [123, 'string', [1, 2, 3], true]
    invalid.each do |recursion|
      context "when ::recursion #{recursion}" do
        let :params do
          {
            recursion: recursion,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Enum\['no', 'yes'\]}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::allow_recursion valid' do
    valid =
      [
        ['none'],
        ['localnets', 'myacl'],
      ]
    valid.each do |allow_recursion|
      context "when ::allow_recursion #{allow_recursion}" do
        let :params do
          {
            allow_recursion: allow_recursion,
          }
        end

        it {
          is_expected.to contain_concat_fragment('options.conf+10-main.dns').with(
            target:  '/etc/bind/named.conf.options',
            content: %r{allow-recursion { #{allow_recursion.join("; ")}; };.*},
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::allow_recursion invalid' do
    invalid = [123, 'string', true, { trusted: ['localhost'] }]
    invalid.each do |allow_recursion|
      context "when ::allow_recursion #{allow_recursion}" do
        let :params do
          {
            allow_recursion: allow_recursion,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects an Array}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::allow_query valid' do
    valid =
      [
        ['none'],
        ['localnets', 'myacl'],
      ]
    valid.each do |allow_query|
      context "when ::allow_query #{allow_query}" do
        let :params do
          {
            allow_query: allow_query,
          }
        end

        it {
          is_expected.to contain_concat_fragment('options.conf+10-main.dns').with(
            target:  '/etc/bind/named.conf.options',
            content: %r{allow-query { #{allow_query.join("; ")}; };.*},
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::allow_query invalid' do
    invalid = [123, 'string', true, { trusted: ['localhost'] }]
    invalid.each do |allow_query|
      context "when ::allow_query #{allow_query}" do
        let :params do
          {
            allow_query: allow_query,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects an Array}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::forward valid' do
    valid = ['only', 'first']
    valid.each do |forward|
      context "when ::forward #{forward}" do
        let :params do
          {
            forward: forward,
          }
        end

        it {
          is_expected.to contain_concat_fragment('options.conf+10-main.dns').with(
            target:  '/etc/bind/named.conf.options',
            content: %r{forward #{forward};},
          )
        }
        it { is_expected.to compile }
      end
    end
    # Optional parameter check
    context 'when ::forward :undef' do
      let :params do
        {
          forward: :undef,
        }
      end

      it {
        is_expected.to contain_concat_fragment('options.conf+10-main.dns').with(
          target:  '/etc/bind/named.conf.options',
        ).without(
          content: %r{\nforward .*;},
        )
      }
      it { is_expected.to compile }
    end
  end

  context 'when ::forward invalid' do
    invalid = [123, 'string', true, { forward: ['first', 'only'] }]
    invalid.each do |forward|
      context "when ::forward #{forward}" do
        let :params do
          {
            forward: forward,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects an undef value or a match for Enum\['first', 'only'\]}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::forwarders valid' do
    valid =
      [
        ['1.1.1.1'],
        ['8.8.8.8', '8.8.4.4'],
      ]
    valid.each do |forwarders|
      context "when ::forwarders #{forwarders}" do
        let :params do
          {
            forwarders: forwarders,
          }
        end

        it {
          is_expected.to contain_concat_fragment('options.conf+10-main.dns').with(
            target:  '/etc/bind/named.conf.options',
            content: %r{forwarders { #{forwarders.join("; ")}; };.*},
          )
        }
        it { is_expected.to compile }
      end
    end
  end

  context 'when ::forwarders invalid' do
    invalid = [123, 'string', true, { hosts: ['1.1.1.1', '8.8.8.8', '8.8.4.4'] }]
    invalid.each do |forwarders|
      context "when ::forwarders #{forwarders}" do
        let :params do
          {
            forwarders: forwarders,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects an Array}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::acls valid' do
    acls =
      {
        'trusted' =>
          [
            'localhost',
          ],
        'untrusted' =>
          [
            'localnets',
            '192.168.0.0/16',
            '10.0.0.0/8',
          ],
      }
    context "when ::acls #{acls}" do
      let :params do
        {
          acls: acls,
        }
      end

      acls.each do |key, value|
        value.each do |address|
          it {
            is_expected.to contain_concat_fragment('named.conf+10-main.dns').with(
              target:  '/etc/bind/named.conf',
              content: %r{acl "#{key}"  \{\n.*#{address};\n}m,
            )
          }
        end
      end
      it { is_expected.to compile }
    end
  end

  context 'when ::acls invalid' do
    invalid = [123, 'string', true, ['localhost', 'localnets', '10.0.0.0/8']]
    invalid.each do |acls|
      context "when ::acls #{acls}" do
        let :params do
          {
            acls: acls,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Hash}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::keys valid' do
    generated_keys =
      {
        'key0' =>
          {
            algorithm: 'hmac-md5',
            filename:  'key0.key',
            keysize:   512,
          },
      }
    static_keys =
      {
        'key0' =>
          {
            algorithm: 'hmac-md5',
            filename:  'key0.key',
            secret:    'ABCDEFGHIJK0123456789',
          },
      }
    context "when ::keys #{generated_keys}" do
      let :params do
        {
          keys: generated_keys,
        }
      end

      generated_keys.each do |key, value|
        it {
          is_expected.to contain_exec("create-#{key}.key").with(
            command: "/usr/sbin/rndc-confgen -a -c /etc/bind/#{key}.key -b #{value[:keysize]} -k #{key}",
            creates: "/etc/bind/#{key}.key",
            before:  %r{^\[Class\[Dns::Config\]{.*}, \"File\[/etc/bind/#{key}.key\]\"\]$},
            notify:  %r{^Class\[Dns::Service\]},
          )
        }
        it {
          is_expected.to contain_file("/etc/bind/#{key}.key").with(
            owner: 'root',
            group: 'bind',
            mode:  '0640',
          )
        }
        it {
          is_expected.to contain_concat_fragment("named.conf+20-key-#{key}.dns").with(
            target:  '/etc/bind/named.conf',
            content: %r{^include \"/etc/bind/#{key}.key\";},
          )
        }
      end
      it { is_expected.to compile }
    end

    context "when ::keys #{static_keys}" do
      let :params do
        {
          keys: static_keys,
        }
      end

      static_keys.each do |key, value|
        it {
          is_expected.to contain_file("/etc/bind/#{key}.key").with(
            owner:   'bind',
            group:   'bind',
            mode:    '0640',
            content: %r{^key "#{key}".*algorithm #{value[:algorithm]};.*secret "#{value[:secret]}";}m,
          )
        }
        it {
          is_expected.to contain_concat_fragment("named.conf+20-key-#{key}.dns").with(
            target:  '/etc/bind/named.conf',
            content: %r{^include \"/etc/bind/#{key}.key\";},
          )
        }
      end
      it { is_expected.to compile }
    end
  end

  context 'when ::keys invalid' do
    invalid = [123, 'string', true, ['rndc.key', 'key0.key', 'key1.key']]
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

  context 'when ::enable_views valid' do
    context 'when ::enable_views true' do
      let :params do
        {
          enable_views: true,
        }
      end

      it {
        is_expected.to contain_file('/etc/bind/views').with(
          ensure: 'directory',
          owner:  'root',
          group:  'bind',
          mode:   '0755',
        )
      }
      it { is_expected.to compile }
    end

    context 'when ::enable_views false' do
      let :params do
        {
          enable_views: false,
        }
      end

      it { is_expected.not_to contain_file('/etc/bind/views') }
      it { is_expected.to compile }
    end
  end

  context 'when ::enable_views invalid' do
    invalid = [123, 'string', ['global', 'no-recursion']]
    invalid.each do |enable_views|
      context "when ::enable_views #{enable_views}" do
        let :params do
          {
            enable_views: enable_views,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Boolean}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::views valid' do
    views =
      {
        'raft.com.view' =>
          {
            match_clients:   ['trusted'],
            allow_recursion: ['any'],
            recursion:       'yes',
            forward:         'only',
            forwarders:      ['8.8.8.8', '1.1.1.1'],
          },
      }
    context "when ::views #{views}" do
      let :params do
        {
          # dns::view dependency
          enable_views: true,
          views:        views,
        }
      end

      views.each do |key, value|
        it {
          is_expected.to contain_concat("/etc/bind/views/#{key}.conf").with(
            owner:   'root',
            group:   'bind',
            mode:    '0640',
            replace: true,
            before:  %r{Concat\[/etc/bind/zones.conf\]},
            notify:  %r{Class\[Dns::Service\]},
          )
        }
        it {
          is_expected.to contain_concat_fragment("dns_view_header_#{key}.dns").with(
            # rubocop:disable LineLength
            content: %r{view "#{key}".*forward #{value[:forward]}.*forwarders { #{value[:forwarders].join('; ')}; };.*match-clients { #{value[:match_clients].join('; ')}; };.*allow-recursion { #{value[:allow_recursion].join('; ')}; };.*recursion #{value[:recursion]};}m,
            # rubocop:enable LineLength
          )
        }
      end
      it { is_expected.to compile }
    end
  end

  context 'when ::views invalid' do
    invalid = [123, 'string', ['recursion', 'forward']]
    invalid.each do |views|
      context "when ::views #{views}" do
        let :params do
          {
            views: views,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Hash}) }
        it { is_expected.not_to compile }
      end
    end
    context 'when ::views enable_views: false' do
      views =
        {
          'raft.com.view' =>
            {
              match_clients:   ['trusted'],
              allow_recursion: ['any'],
              recursion:       'yes',
              forward:         'only',
              forwarders:      ['8.8.8.8', '1.1.1.1'],
            },
        }
      let :params do
        {
          enable_views: false,
          views:        views,
        }
      end

      it { is_expected.to raise_error(Puppet::Error, %r{\$dns::enable_views to true in order to use dns::view}) }
      it { is_expected.not_to compile }
    end
  end

  context 'when ::zones valid' do
    zones =
      {
        'raft.com' =>
          {
            manage_file: true,
            zonetype:    'master',
            soa:         'seed.raft.com',
            soaip:       '192.168.0.1',
          },
        'waddle.com' =>
          {
            manage_file: true,
            zonetype:    'master',
            soa:         'seed.waddle.com',
            soaip:       '192.168.0.1',
          },
      }

    context "when ::zones #{zones}" do
      let :params do
        {
          zones: zones,
        }
      end

      zones.each do |key, value|
        it {
          is_expected.to contain_dns__zone(key).with(
            manage_file: value[:manage_file],
            soa:         value[:soa].to_s,
            soaip:       value[:soaip].to_s,
          )
        }
        it {
          is_expected.to contain_file("/var/cache/bind/zones/db.#{key}").with(
            owner:   'bind',
            group:   'bind',
            mode:    '0644',
            content: %r{IN SOA #{value[:soa]}.*IN NS #{value[:soa]}.*IN A #{value[:soaip]}}m,
            notify:  %r{Class\[Dns::Service\]},
          )
        }
        it {
          is_expected.to contain_concat_fragment("dns_zones+10__GLOBAL__#{key}.dns").with(
            target:  '/etc/bind/zones.conf',
            content: %r{zone "#{key}".*type #{value[:zonetype]}.*file "/var/cache/bind/zones/db.#{key}"}m,
          )
        }
      end
      it { is_expected.to compile }
    end
  end

  context 'when ::zones invalid' do
    invalid = [123, 'string', true, ['raft.com', 'waddle.com']]
    invalid.each do |zones|
      context "when ::zones #{zones}" do
        let :params do
          {
            zones: zones,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Hash}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::additional_options valid' do
    additional_options =
      {
        'listen-on' => '{ 192.168.0.1; }',
      }

    context "when ::additional_options #{additional_options}" do
      let :params do
        {
          additional_options: additional_options,
        }
      end

      additional_options.each do |key, value|
        it {
          is_expected.to contain_concat_fragment('options.conf+10-main.dns').with(
            target:  '/etc/bind/named.conf.options',
            content: %r{#{key} #{value}},
          )
        }
      end
      it { is_expected.to compile }
    end
  end

  context 'when ::additional_options invalid' do
    invalid = [123, 'string', true, ['raft.com', 'waddle.com']]
    invalid.each do |additional_options|
      context "when ::additional_options #{additional_options}" do
        let :params do
          {
            additional_options: additional_options,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Hash}) }
        it { is_expected.not_to compile }
      end
    end
  end
end

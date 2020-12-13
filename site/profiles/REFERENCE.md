# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`profiles::apt`](#profilesapt): Manages Debian's Advanced Package Tool (APT) configuration/behaviour
Responsible for repository sources, package pins, repository GPG keys, etc
Predominantly a wrapper around the 'puppetlabs-apt' Forge module
* [`profiles::bootstrap`](#profilesbootstrap): Performs minimal alteration required for a full Puppet run at first boot
This profile operates within a "limited" Debian Preseed chrooted environment
Consequently extending this profile and its subclasses is discouraged
* [`profiles::bootstrap::node`](#profilesbootstrapnode): Specifies how a targeted node's Puppet agent obtains its catalog
Supports both a client-only and standalone (a.k.a. serverless) configuration
* [`profiles::bootstrap::node::agent`](#profilesbootstrapnodeagent): Specifies the Puppet agent's targeted Puppet server for obtain its catalog
Configures the Puppet agent to run at startup via systemd
* [`profiles::bootstrap::node::master`](#profilesbootstrapnodemaster): Configures a Puppet master to support a serverless Puppet deployment
Binds the Puppet master daemon to localhost for isolated catalog generation
* [`profiles::bootstrap::seed`](#profilesbootstrapseed): Unique, singular "seed" node configuration
Manually specifies the static "seed" role fact
* [`profiles::dhcp`](#profilesdhcp): Manages isc-dhcp-server configuration/behaviour
Responsible for subnet allocation, host reservations, (i)PXE URIs, etc
Predominantly a wrapper around the 'puppet-dhcp' Forge module
* [`profiles::disk`](#profilesdisk): Manages the node's "external" block devices (i.e. non-root)
Performs filesystem creation and manages mount behaviours
* [`profiles::dns`](#profilesdns): Manages ISC BIND DNS server (bind9) configuration/behaviour
Responsible for zone allocation, recursion & forwarding, rndc keys, etc.
Predominantly a wrapper around the 'theforeman-dns' Forge module
* [`profiles::network`](#profilesnetwork): Manages the node's network interface(s), static route(s), rule(s)
Leverages the '/etc/network/interfaces' consumed by `ifup/ifdown`

## Classes

### `profiles::apt`

Manages Debian's Advanced Package Tool (APT) configuration/behaviour
Responsible for repository sources, package pins, repository GPG keys, etc
Predominantly a wrapper around the 'puppetlabs-apt' Forge module

#### Examples

##### 

```puppet
include profiles::apt
```

#### Parameters

The following parameters are available in the `profiles::apt` class.

##### `purge`

Data type: `Hash`

Specify APT repository configuration file(s) to empty contents
Wrapper parameter: 'puppetlabs-apt' module class parameter

Default value: `{}`

##### `sources`

Data type: `Hash`

Specify APT respository URI and corresponding settings (e.g. repos)
Wrapper parameter: 'puppetlabs-apt' module class parameter

Default value: `{}`

### `profiles::bootstrap`

Performs minimal alteration required for a full Puppet run at first boot
This profile operates within a "limited" Debian Preseed chrooted environment
Consequently extending this profile and its subclasses is discouraged

#### Examples

##### 

```puppet
include profiles::bootstrap
```

#### Parameters

The following parameters are available in the `profiles::bootstrap` class.

##### `seed`

Data type: `Boolean`

Specifies additional bootstrapping configuration for the given "seed" node

Default value: ``false``

### `profiles::bootstrap::node`

Specifies how a targeted node's Puppet agent obtains its catalog
Supports both a client-only and standalone (a.k.a. serverless) configuration

#### Examples

##### 

```puppet
include profiles::bootstrap
```

#### Parameters

The following parameters are available in the `profiles::bootstrap::node` class.

##### `serverless`

Data type: `Boolean`

Installs and configures a locally ran Puppet master for catalog generation

Default value: ``true``

### `profiles::bootstrap::node::agent`

Specifies the Puppet agent's targeted Puppet server for obtain its catalog
Configures the Puppet agent to run at startup via systemd

#### Examples

##### 

```puppet
include profiles::bootstrap
```

#### Parameters

The following parameters are available in the `profiles::bootstrap::node::agent` class.

##### `puppet_server`

Data type: `Stdlib::Host`

Specifies the hostname of the Puppet server

Default value: `'localhost'`

### `profiles::bootstrap::node::master`

Configures a Puppet master to support a serverless Puppet deployment
Binds the Puppet master daemon to localhost for isolated catalog generation

#### Examples

##### 

```puppet
include profiles::bootstrap
```

### `profiles::bootstrap::seed`

Unique, singular "seed" node configuration
Manually specifies the static "seed" role fact

#### Examples

##### 

```puppet
include profiles::bootstrap
```

### `profiles::dhcp`

Manages isc-dhcp-server configuration/behaviour
Responsible for subnet allocation, host reservations, (i)PXE URIs, etc
Predominantly a wrapper around the 'puppet-dhcp' Forge module

* **See also**
  * https://tools.ietf.org/html/rfc2132
    * https://tools.ietf.org/html/rfc3397

#### Examples

##### 

```puppet
include profiles::dhcp
```

#### Parameters

The following parameters are available in the `profiles::dhcp` class.

##### `service_ensure`

Data type: `Stdlib::Ensure::Service`

Specify whether the isc-dhcp-server service state
Wrapper parameter: 'puppet-dhcp' module class parameter

Default value: `'stopped'`

##### `interfaces`

Data type: `Array[String[1]]`

Specify interface(s) for isc-dhcp-server to listen on (UDP/67)
Wrapper parameter: 'puppet-dhcp' module class parameter

Default value: `[]`

##### `dnsdomain`

Data type: `Array[String[1]]`

Specify "global" DNS domains (Option 15)
First DNS domain element is assigned the 'domain-name' option
Subsequent DNS domain element(s) are utilised with DDNS zones
Wrapper parameter: 'puppet-dhcp' module class parameter

Default value: `[]`

##### `nameservers`

Data type: `Array[Stdlib::IP::Address::V4]`

Specify "global" DNS nameserver(s) (Option 6)
Wrapper parameter: 'puppet-dhcp' module class parameter

Default value: `[]`

##### `dnssearchdomains`

Data type: `Array[String[1]]`

Specify "global" DNS "search" domains (Option 119)
Wrapper parameter: 'puppet-dhcp' module class parameter

Default value: `[]`

##### `ntpservers`

Data type: `Array[Variant[Stdlib::Fqdn,Stdlib::IP::Address]]`

Specify Network Time Protocol (NTP) server(s) (Option 4)
Wrapper parameter: 'puppet-dhcp' module class parameter

Default value: `[]`

##### `pools`

Data type: `Hash[String, Hash]`

Specify DHCP pool(s)/zone(s) attributes (e.g. subnets, gateway, etc)
Wrapper parameter: 'puppet-dhcp' module class parameter

Default value: `{}`

### `profiles::disk`

Manages the node's "external" block devices (i.e. non-root)
Performs filesystem creation and manages mount behaviours

#### Examples

##### 

```puppet
include profiles::disk
```

#### Parameters

The following parameters are available in the `profiles::disk` class.

##### `filesystems`

Data type: `Hash`

Format target block device(s) with specified filesystem
Arbritrary filesystem options during initial creation/format can be specified
Wrapper parameter: 'puppetlabs-lvm' module filesystem custom "type"
Title: udev disk by-id value (recommended)

Default value: `{}`

##### `mounts`

Data type: `Hash`

Mount options of the target block device(s)
Title: udev disk by-uuid (filesystem)

Default value: `{}`

### `profiles::dns`

Manages ISC BIND DNS server (bind9) configuration/behaviour
Responsible for zone allocation, recursion & forwarding, rndc keys, etc.
Predominantly a wrapper around the 'theforeman-dns' Forge module

#### Examples

##### 

```puppet
include profiles::dns
```

#### Parameters

The following parameters are available in the `profiles::dns` class.

##### `service_ensure`

Data type: `Stdlib::Ensure::Service`

Specify the bind9 service state
Wrapper parameter: 'theforeman-dns' module class parameter

Default value: `'stopped'`

##### `recursion`

Data type: `Enum['yes', 'no']`

Specify whether the DNS server operates in "Recursive Mode"
Ref: "Recursive Mode" definition (https://tools.ietf.org/html/rfc7719)
Wrapper parameter: 'theforeman-dns' module class parameter

Default value: `'no'`

##### `allow_recursion`

Data type: `Array[String]`

Specify the *global* "address(es)" allowed to perform "recursive" queries
Wrapper parameter: 'theforeman-dns' module class parameter

Default value: `['none']`

##### `allow_query`

Data type: `Array[String]`

Specify the *global* "address(es)" allowed to perform managed zone queries
Wrapper parameter: 'theforeman-dns' module class parameter

Default value: `['none']`

##### `forward`

Data type: `Optional[Enum['only', 'first']]`

Specify the "type" of DNS query forwarding to be performed
Ref: "Forwarders" definition (https://tools.ietf.org/html/rfc7719)
Wrapper parameter: 'theforeman-dns' module class parameter

Default value: ``undef``

##### `forwarders`

Data type: `Array[Stdlib::IP::Address::V4]`

Specify the DNS server(s) IPs that will answer forwarded DNS queries
Leveraging Stdlib IPv4 type to adhere to 'bind9' compatibility
Wrapper parameter: 'theforeman-dns' module class parameter

Default value: `[]`

##### `acls`

Data type: `Hash[String, Array[String]]`

Specify Access Control List(s) (ACL) statement(s) in 'named.conf'
Ref: "acls" section (https://bind9.readthedocs.io/en/latest/reference.html)
Wrapper parameter: 'theforeman-dns' module class parameter

Default value: `{}`

##### `keys`

Data type: `Hash[String, Hash]`

Specify local Remote Name Daemon Control (RNDC) key(s)
Wrapper parameter: 'theforeman-dns' module class parameter

Default value: `{}`

##### `zones`

Data type: `Hash[String, Hash]`

Specify authoritative/managed DNS "zone(s)"
Ref: "Zones" definition (https://tools.ietf.org/html/rfc7719#section-6)
Wrapper parameter: 'theforeman-dns' module class parameter

Default value: `{}`

##### `additional_options`

Data type: `Hash[String, Data]`

Specify additional generic/free-form options appended to 'options.conf'
Wrapper parameter: 'theforeman-dns' module class parameter

Default value: `{}`

### `profiles::network`

Manages the node's network interface(s), static route(s), rule(s)
Leverages the '/etc/network/interfaces' consumed by `ifup/ifdown`

#### Examples

##### 

```puppet
include profiles::network
```

#### Parameters

The following parameters are available in the `profiles::network` class.

##### `interfaces`

Data type: `Hash`

Specifies the network interface(s) to manage

Default value: `{}`

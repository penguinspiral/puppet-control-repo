# profiles

Part of the Puppet best-practice "Roles & Profiles" design pattern for
providing an interface between "business logic" and reusable Puppet modules.

The 'profiles' module contains the "business logic" instructing the usage of
application/component modules for composing the environment. Classes contained
within this module are site-specific, reusable groupings of Puppet modules.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with profiles](#setup)
    * [What profiles affects](#what-profiles-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with profiles](#beginning-with-profiles)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module contains "business logic" in addition to consuming site-specific default
values, as a result it is **not** suitable for external consumption. Unlike
application/component modules this Puppet module does not need to be reusable
across deployments - it specifies the deployment!

### Usage

Classes specified within this module serve as discrete, reusable components that
are referenced in Hiera (`data/roles/$role.yaml`) for comprising a given "role".
This Hiera-defined "role" lookup differs from the typical implementation of the
`roles` module explicitly "including" the `profiles` classes.

To facilitate a Hiera-defined "role" lookup the environment's `manifests/site.pp`
performs a Puppet `lookup()` call which generates a unique array of `profiles`
classes.

## Setup

### What profiles affects

The nature of the `profiles` module means that all hosts managed with Puppet are
affected. Refer to environment specific `data/roles/$role.yaml` for determining
which `profiles` classes are applied for a given `role`.

A common set of `profiles` classes are incorporated by _all_ `roles` (e.g.
`profiles::ssh`), however these standalone `profiles` classes have been kept
distinct so as to avoid a monolithic "base" `profile`.

### Setup Requirements

Given its site-specific ties the `profiles` module is entirely reliant upon a
Debian GNU/Linux 10.0 "Buster" environment deployed as part of the
[penguinspiral/seed-installer](https://github.com/penguinspiral/seed-installer).

All `profiles` module's classes are designed to work with the Debian GNU/Linux
distribution. Other operating system distributions are, as per the `profiles`
module's `metadata.json`, explicitly not supported.

### Beginning with profiles

As per the Puppet best practice "Roles & Profiles" pattern a "role" consists of
one or more "profiles". Consumption of `profiles` classes are done via
Hiera-defined "role" lookups in discrete, standalone `data/role/$role.yaml` data
files.

## Usage

Classes contained within the `profiles` module are intended to be consumed by
means of Hiera-defined "role" lookups. "Metaprofiles" serve as the exception in
which related `profiles` sub-classes are explicitly listed in Puppet manifests.

### Use cases

FTP server:
```
# data/roles/fileserver.yaml

classes:
  - profile::network
  - profile::apt
  - profile::ssh
  - profile::ftp::server
```

DHCP server:
```
# data/roles/router.yaml

classes:
  - profile::network
  - profile::apt
  - profile::ssh
  - profile::dhcp::server
  - profile::dns::server
```

PXE server:
```
# data/roles/pxe.yaml

classes:
  - profile::network
  - profile::apt
  - profile::ssh
  - profile::dhcp::server
  - profile::tftp::server
```

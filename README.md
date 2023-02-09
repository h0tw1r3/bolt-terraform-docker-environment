# Bolt Terraform Docker Environment (btde)

[Puppet Bolt] project using [Terraform] and [Docker] to create and manage
full system containers for local development and testing.

This document is geared towards deploying a Puppet server and agents,
but anything's possible. Most configuration is done in [docker.yaml].

## Requirements

1. Only tested on Linux. Patches to support other OS's welcome.
1. Recent version of Puppet Bolt. _Tested with 3.26.2._
1. Working _local_ docker, recent version. _Tested with 20.10.17_.
1. Ensure the `control-repo` git repository is checked out and in the parent
   folder to this bolt project.
   Alternatively, modify the appropriate volume in [docker.yaml].

## Usage

### Infrastructure

#### Configuration

* Docker containers are defined in [docker.yaml].
* Terraform variables are set in [inventory.yaml] under `vars.terraform`.

#### Create

```sh
bolt plan run btde::terraform
bolt plan run btde::bootstrap
```

#### Destroy

```sh
bolt plan run btde::terraform destroy=true
```

#### View

```sh
bolt inventory show
```

### Nodes

#### Connect

The [btde::bootstrap] plan automatically configures your local ssh client for
easy ssh access to the test infrastructure. See `~/.ssh/btde_config` and
the [ssh_config] plan.

```sh
ssh puppet-server
```

#### Provision

Provision the puppet primary first

```sh
ssh puppet-server
puppet apply /etc/puppetlabs/code/environment/production/manifests/site.pp
```

Then any agents can connect to the primary:

```sh
ssh puppet-agent
puppet agent -t
```

[btde::bootstrap]: manifests/bootstrap.pp
[inventory.yaml]: inventory.yaml
[docker.yaml]: docker.yaml
[ssh_config]: plans/local/ssh_config.pp
[Docker]: https://docker.com
[Terraform]: https://terraform.io
[Puppet Bolt]: https://puppet.com/docs/bolt/

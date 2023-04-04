# Bolt Terraform Docker Environment (btde)

[Puppet Bolt] project using [Terraform] and [Docker] to create and manage
full system containers for local development and testing.

This project is geared towards deploying a Puppet server and agents,
but anything's possible.

## Requirements

1. Only tested on Linux.
   _Welcome contributions to support other OS's!_
1. Recent version of [Puppet Bolt].
   _Tested with 3.26.2._
1. Working _local_ docker, recent version, usable by your unprivileged user.
   _Tested with 20.10.17_.

## Usage

### Configuration

* Docker containers are defined in [containers.yaml].
  See [local.tf] for a list of supported images.
  _Currently only Ubuntu, see [OS Support]._
* Terraform variables may be set in [inventory.yaml] under `vars.terraform`.
  See [variables.tf] for possible variables and default values.

### OS Support

Currently, only Ubuntu LTS 14.04 through 20.04 are supported. Additional
images will be added as I need them, or through contributions.

Adding support is relatively straightforward if you're familiar with
Dockerfiles.

Relative to the [terraform/docker] folder:

1. Create a folder under [images] for the OS name or family.
   Example: _centos_
2. Create a `Dockerfile` in the OS folder.
3. Add the image to the `images` map in [local.tf]. Example:

       "centos-9" = {
         name = "btde.local/centos:stream9"
         dockerfile = "images/centos/Dockerfile"
         repo = "centos"
         tag = "stream9"
       }

### Infrastructure

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

In addition to basic container setup, the [btde::bootstrap] plan configures
your local ssh client for easy access to the container infrastructure using
just the container name.
See `~/.ssh/btde_config` and the [ssh_config] plan for details.

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

[btde::bootstrap]: plans/bootstrap.pp
[inventory.yaml]: inventory.yaml
[containers.yaml]: containers.yaml
[ssh_config]: plans/local/ssh_config.pp
[Docker]: https://docker.com
[Terraform]: https://terraform.io
[Puppet Bolt]: https://puppet.com/docs/bolt/
[variables.tf]: terraform/docker/variables.tf
[local.tf]: terraform/docker/local.tf
[terraform/docker]: terraform/docker
[images]: terraform/docker/images

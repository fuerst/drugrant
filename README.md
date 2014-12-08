drugrant
========

Drupal-ready Vagrant VM based on an Ubuntu 14.04 LAMP stack.

It allows easy setup of VMs for running Drupal 7 or 8 without installing anything
besides Virtualbox and Vagrant.

Getting a Drupal instance up and running that way makes evaluation or demonstration
of ideas, Drupal modules and Drupal distributions easy.

## What you get

* LAMP stack with Apache 2.4, MySQL 5.5 and PHP 5.5.
* MySQL and PHP optimized for running Drupal.
* MySQL is available to the VM host at port 3306 (customizable).
* Apache Solr preinstalled and available to the VM host at port 8080 (customizable).
* Xdebug installed for debugging using an IDE.
* Memcached internal available at default port 11211 and set to 128 MB caching size.

## Requirements

* [Virtualbox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)

## Usage

```
vagrant up --provider virtualbox
```

This command will load and create a VM controlled by Vagrant.
It also installs the current stable Drupal version.

Add this to your hosts file to access the VM:

```
192.168.50.2 drugrant.dev.local
```

Fire it up in your browser using http://drugrant.dev.local.
User and Password is: admin / admin.

### Install Drupal

* Drupal 7 (latest): `PROVISION_ARGS="install drupal 7" vagrant provision`
* Drupal 8 (latest): `PROVISION_ARGS="install drupal 8" vagrant provision`
* Specific version e.g. Drupal 7.30: `PROVISION_ARGS="install drupal 7.30" vagrant provision`

## Using more than one Drupal VMs

You can customize the Name and IP of your VM by adding a file _Vagrantfile.local_
in the same directory where _Vagrantfile_ is located. It allows customization of
all `$my_` variables used in the Vagrantfile.

Example to use a second VM using a different IP and hostname:

```
$my_name = "drugrant2"
$my_ip   = "192.168.50.3"
```

Have a look at _Vagrantfile_ for more customizable parameters.

## Debugging using Xdebug

_Examples for Netbeans IDE_

### Web UI

Go to the project settings, choose _Run configuration_:

* Configuration: <default>
* Run As: Local Web Site
* Project URL: http://drugrant.dev.local/
* Index File: index.php

### Drush commands

Go to the project settings, choose _Run configuration_:

* Configuration: drush (create, if not exists)
* Run As: Script
* Index File: sites/all/bin/drush/drush.php

Now start Debugging in Netbeans using _Debug > Debug Project_. Netbeans waits for
a debugger connecting to it. Back in the VM use the command `ddrush` instead of
`drush`. This just sets necessary environment variables and runs the usual
`drush` command.

## Notes

* Drupal < 7.14 is not supported.

## TODO

* The box is available for Virtualbox only. VMware Fusion box is under progress.

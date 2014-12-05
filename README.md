drugrant
========

Drupal-ready Vagrant VM based on Ubuntu 14.04 LAMP stack.

## Requirements

* Virtualbox
* Vagrant

## Usage

```
vagrant up --provider virtualbox
```

This command will create a VM controlled by Vagrant.

At this to your hosts file to access the VM:

```
192.168.50.2 drugrant.dev.local
```

### Install Drupal

* Drupal 7: `PROVISION_ARGS="install_drupal7" vagrant provision`
* Drupal 8: `PROVISION_ARGS="install_drupal8" vagrant provision`

## TODO

* The box is available for Virtualbox only. VMware Fusion box is under progress.
* Install stable Drupal version at first provisioning.
* More documentation.

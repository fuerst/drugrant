# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Load local settings which will override the defaults.
load 'Vagrantfile.local' if File.exists? 'Vagrantfile.local'

# Example for local settings file "Vagrantfile.local".
#   $my_name = "my_drugrant"
#   $my_ip   = "192.168.50.3"
#   $my_cpus = 2
#   $my_sql_host_port = 3307

# Default settings - don't touch them here. Use a file "Vagrantfile.local"
# if you want to change the defaults.
$my_name             = "drugrant" unless defined? $my_name
$my_hostname         = "#{$my_name}.dev.local" unless defined? $my_hostname
$my_ip               = "192.168.50.2" unless defined? $my_ip
$my_box              = "drugrant" unless defined? $my_box
$my_box_url          = "http://fuerstnet.de/vagrant_boxes/drugrant-virtualbox.box" unless defined? $my_box_url
$my_box_url_vmware   = "http://fuerstnet.de/vagrant_boxes/drugrant-vmware-fusion.box" unless defined? $my_box_url_vmware
$my_memory           = "512" unless defined? $my_memory
$my_nfs              = true unless defined? $my_nfs
$my_gui              = false unless defined? $my_gui
$my_noproxy          = "#{$my_hostname}" unless defined? $my_noproxy
$my_halt_timeout     = 30 unless defined? $my_halt_timeout
$my_cpus             = 1 unless defined? $my_cpus
$my_sql_host_port    = 3306 unless defined? $my_sql_host_port
$my_solr_host_port   = 8080 unless defined? $my_solr_host_port

Vagrant.configure("2") do |config|
    # Use SSH key from VM host user inside the VM.
    config.ssh.forward_agent = true

    # Virtualbox Folder Sharing is more faster using NFS in Mac/Linux.
    # With VMware Fusion 6.0.2. (HGFS) files where shared incomplete.
    # See #26 https://communities.vmware.com/thread/438804
    # and https://communities.vmware.com/thread/462747
    config.vm.synced_folder ".", "/vagrant", type: "nfs"

    config.vm.box = "#{$my_box}"
    config.vm.box_url = "#{$my_box_url}"

    # Static IP for accessing the IP. Use in /etc/hosts (UNIX/Mac) or
    # c:\windows\system\drivers\etc\hosts (Windows) like this:
    # 192.168.50.2 drugrant.dev.local
    config.vm.network :private_network, ip: "#{$my_ip}"

    config.vm.hostname = "#{$my_hostname}"

    config.vm.graceful_halt_timeout = $my_halt_timeout

    config.vm.network "forwarded_port", guest: 3306, host: "#{$my_sql_host_port}", protocol: 'tcp'
    config.vm.network "forwarded_port", guest: 8080, host: "#{$my_solr_host_port}", protocol: 'tcp'

    config.vm.provider :virtualbox do |vb, override|
        vb.gui = $my_gui
        vb.customize [
            "modifyvm", :id,
            "--memory", "#{$my_memory}",
            "--cpus", "#{$my_cpus}"
        ]
    end

    config.vm.provider :vmware_fusion do |vb, override|
        vb.gui = $my_gui
        vb.vmx["memsize"] = "#{$my_memory}"
        vb.vmx["numvcpus"] = "#{$my_cpus}"
        override.vm.box_url = "#{$my_box_url_vmware}"
    end

    config.vm.provision :shell do |shell|
        shell.path = "provisioning.sh"
        shell.args = "#{$my_ip} #{$my_hostname} #{ENV['PROVISION_ARGS']}"
    end
end

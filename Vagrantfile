# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Default Konfiguration - für lokale Anpassungen nicht hier ändern.
# Anpassungen dieser Variablen sind in einer Datei "Vagrantfile.local" möglich.
$my_name             = "drugrant"
$my_hostname         = "#{$my_name}.dev.local" unless defined? $my_hostname
$my_ip               = "192.168.50.2"
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

# Lokale Anpassungen laden.
# Beispiel für eine Vagrantfile.local, mit der eine weitere VM im Host gestartet
# werden kann, um in einem anderen Branch arbeiten zu können:
#   $my_name     = "my_drugrant"
#   $my_ip   = "192.168.50.3"
#   $my_cpus = 2
#   $my_sql_host_port = 3307

load 'Vagrantfile.local' if File.exists? 'Vagrantfile.local'

Vagrant.configure("2") do |config|
    # SSH-Key des Host-Users innerhalb der VM nutzen
    config.ssh.forward_agent = true

    # Virtualbox Folder Sharing ist unter Mac/Linux performanter mit NFS.
    # Mit VMware Fusion 6.0.2. (HGFS) wurden Dateien unvollständig übertragen,
    # siehe #26 https://communities.vmware.com/thread/438804
    # bzw. https://communities.vmware.com/thread/462747
    config.vm.synced_folder ".", "/vagrant", type: "nfs"

    config.vm.box = "#{$my_box}"
    config.vm.box_url = "#{$my_box_url}"

    # Statische IP zum Zugriff auf die VM. Kann in eigener /etc/hosts
    # folgendermaßen verwendet werden (Beispiel):
    # 192.168.50.2 drugrant.dev.local
    config.vm.network :private_network, ip: "#{$my_ip}"

    config.vm.hostname = "#{$my_hostname}"

    config.vm.graceful_halt_timeout = $my_halt_timeout

    config.vm.network "forwarded_port", guest: 3306, host: "#{$my_sql_host_port}", protocol: 'tcp'

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

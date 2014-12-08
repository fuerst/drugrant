#!/usr/bin/env bash
#
# Provisioning für Vagrant
# Siehe http://docs.vagrantup.com/v2/provisioning/shell.html
#
# Wichtig: Dieses Skript kann mehr als einmal laufen. Alle Aktionen müssen
# sich entsprechend darauf einstellen.
#
# Hinweis: Lange Befehle nicht per Backslash in mehrere Zeilen auftrennen.
# Vagrant stolpert dabei.
#
# Über die ENV-Variable PROVISION_ARGS können in diesem Skript Dinge getriggert
# werden. Dazu wird im Vagrantfile PROVISION_ARGS als Argument an das Skript
# übergeben. Hier werden die leerzeichen-getrennten Werte einzeln getestet.
# Bash hat je nach Version unterschiedlich Syntax für Regex, daher wird per
# "echo|grep" Kombination getestet.

# Fehler "stdin ist no tty" beim Provisioning verhindern
# sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

# "expr match" throw a "expr: syntax error"
#DRUPAL_VERSION=$(expr match "$@" '.*install drupal \(.*\)')
DRUPAL_VERSION=$(echo $@ | awk -F'install drupal ' '{print $2}')

install_drupal() {
  echo "* Install Drupal ${DRUPAL_VERSION}..."
  mysqladmin drop -f drupal
  mysqladmin create drupal
  [ -d /vagrant/drupal/sites/default ] && chmod 755 /vagrant/drupal/sites/default
  rm -rf /vagrant/drupal
  mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON drupal.* TO 'vagrant'@'192.168.50.1' IDENTIFIED BY 'vagrant'"
  mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON drupal.* TO 'vagrant'@'localhost' IDENTIFIED BY 'vagrant';"
  /home/vagrant/.composer/vendor/bin/drush dl drupal-${DRUPAL_VERSION} --drupal-project-rename=drupal --destination=/vagrant
  cd /vagrant/drupal
  /home/vagrant/.composer/vendor/bin/drush site-install standard --site-name=Drugrant--account-name=admin --account-pass=admin --db-url=mysql://vagrant:vagrant@localhost/drupal -y
  # Depending on the Synced Folder mechanism it may not be possible to get clean
  # write access for Apache.
  chmod -R o+w /vagrant/drupal/sites/default/files
}

# Install Drupal: PROVISION_ARGS="install drupal <VERSION>" vagrant provision
if [[ -n "$DRUPAL_VERSION" && -d /vagrant/drupal ]]
then
  install_drupal
else

  echo "* Upgrade Ubuntu packages..."
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get --yes dist-upgrade

  echo "* Configure Memcached..."
  sed -i 's/^-m 64$/-m 128/g' /etc/memcached.conf
  service memcached restart

  echo "* Configure MySQL..."

  command echo "
  [mysqld]
  innodb_doublewrite = 0
  innodb_flush_log_at_trx_commit = 0
  innodb_flush_method = O_DIRECT
  innodb_log_buffer_size = 4M
  innodb_buffer_pool_size = 128M
  innodb_file_per_table = 1

  default-storage-engine = InnoDB
  query_cache_limit = 128K
  query_cache_size = 128M
  sort_buffer_size = 16M
  bulk_insert_buffer_size = 4M
  tmp_table_size = 32M
  max_heap_table_size = 32M
  key_buffer_size = 64M
  max_allowed_packet = 16M
  thread_stack = 256K
  thread_cache_size = 8
  max-connections = 32
  table-cache = 256
  thread-concurrency = 2
  general_log=0
  general_log_file=/vagrant/mysqlquery.log
  " \
      > '/etc/mysql/conf.d/drupal.cnf'

  # Binary Log ausschalten - produziert unnötigen Overhead
  sed -i -e 's/log_bin/#log_bin/' -e 's/expire_logs_days/#expire_logs_days/' /etc/mysql/my.cnf
  # MySQL von außen per TCP erreichbar
  sed -i -e 's/^bind-address   = 127.0.0.1$/bind-address    = 0.0.0.0/' /etc/mysql/my.cnf
  service mysql restart

  echo "* Configure PHP..."
  command echo "
  memory_limit = 256M

  opcache.enable=On
  opcache.memory_consumption=128
  opcache.interned_strings_buffer=8
  opcache.max_accelerated_files=4000
  opcache.revalidate_freq=0
  opcache.fast_shutdown=1
  opcache.enable_cli=1
  opcache.save_comments=1


  error_log = /var/log/apache2/drupal_error_log
  display_errors = On
  display_startup_errors = On

  post_max_size = 25M
  upload_max_filesize = 25M

  date.timezone = Europe/Berlin

  ; Debugging via Netbeans auf dem Host
  xdebug.default_enable = 1
  xdebug.remote_enable = 1
  xdebug.remote_handler = dbgp
  xdebug.remote_connect_back = 1
  xdebug.remote_port = 9000
  xdebug.remote_autostart = 0
  xdebug.idekey = netbeans-xdebug
  ;xdebug.remote_log = /tmp/xdebug.log
  " \
      > '/etc/php5/apache2/conf.d/drupal.ini'
  cp /etc/php5/apache2/conf.d/drupal.ini /etc/php5/cli/conf.d/drupal.ini

  echo "* Configure Apache..."
  a2enmod rewrite

  # IP and Hostname are provided as argument in "Vagrantfile"
  command echo "<VirtualHost ${1}:80>
      ServerName ${2}

      DocumentRoot /vagrant/drupal

      ErrorLog  /var/log/apache2/drupal_error_log
      CustomLog /var/log/apache2/drupal_access_log combined

      # don't loose time with IP address lookups
      HostnameLookups Off

      # needed for named virtual hosts
      UseCanonicalName Off

      # configures the footer on server-generated documents
      ServerSignature Off

      <Directory "/vagrant/drupal">
        Options FollowSymLinks
        DirectoryIndex index.php
        AllowOverride All
        Require all granted
      </Directory>

  </VirtualHost>" \
      > '/etc/apache2/sites-available/drupal.conf'
  a2ensite drupal.conf

  if [ ! -d /vagrant/drupal ]
  then
    install_drupal
  fi

  service apache2 restart
fi

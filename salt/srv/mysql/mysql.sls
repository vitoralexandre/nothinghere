include: 
  - mysql_repo

mysql:
  pkg.installed:
    - pkgs:
  {% if grains['os_family'] == 'RedHat' %}
      - Percona-Server-server-56
  {% elif grains['os_family'] == 'Debian' %}
      - percona-server-server-5.6
  {% endif %}
      - expect 

  service.running:
  {% if grains['os_family'] == 'RedHat' %}
    - name: mysql
  {% elif grains['os_family'] == 'Debian' %}
    - name: mysql
  {% endif %}
    - enable: True

  file.managed:
    - names: 
      - /etc/my.cnf:
        - source: salt://arquivos/my.cnf

      - /root/configure_mysql.sh:
        - source: salt://arquivos/configure_mysql.sh
        - mode: 755 

  cmd.run:
    - names: 
      - systemctl stop mysqld
      - rm -rf /var/lib/mysql ; mysql_install_db
      - systemctl start mysqld 
      - /etc/init.d/mysql start
      - chmod 755 /root/configure_mysql.sh
#      - /root/configure_mysql.sh
#      - date +%s | sha256sum | base64 | head -c 32 > /root/.mysqlpasswd
#      - mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$(cat /root/.mysqlpasswd)');"
#      - mysql -p$(cat /root/.mysqlpasswd) -e "DELETE FROM mysql.user WHERE User='';"
#      - mysql -p$(cat /root/.mysqlpasswd) -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
#      - mysql -p$(cat /root/.mysqlpasswd) -e "DROP DATABASE IF EXISTS test;"
#      - mysql -p$(cat /root/.mysqlpasswd) -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
#      - mysql -p$(cat /root/.mysqlpasswd) -e "FLUSH PRIVILEGES;"

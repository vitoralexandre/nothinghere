mysql_configure: 
#  cmd.script:
#    - source: salt://arquivos/configure_mysql.sh
#    - user: root
#    - group: root
#    - shell: /bin/bash
  cmd.run: 
    - names: 
      - date +%s | sha256sum | base64 | head -c 32 > /root/.mysqlpasswd
      - MYSQL_PWD="" ; mysql -e "UPDATE mysql.user SET Password=PASSWORD('$(cat /root/.mysqlpasswd)') WHERE User='root';"
      - MYSQL_PWD=$(cat /root/.mysqlpasswd) ; mysql -e "DELETE FROM mysql.user WHERE User='';"
      - MYSQL_PWD=$(cat /root/.mysqlpasswd) ; mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
      - MYSQL_PWD=$(cat /root/.mysqlpasswd) ; mysql -e "DROP DATABASE IF EXISTS test;"
      - MYSQL_PWD=$(cat /root/.mysqlpasswd) ; mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
      - MYSQL_PWD=$(cat /root/.mysqlpasswd) ; mysql -e "FLUSH PRIVILEGES;"

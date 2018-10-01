php-fpm: 
  pkg.installed:
  {% if grains['os_family'] == 'RedHat' %}
    - pkgs: 
      - php-fpm 
      - php-gd 
      - php-imap 
      - php-mysql 
      - php-soap
      - php-xml 
      - php-pdo
      - php-mcrypt
      - php-mbstring
  {% elif grains['os_family'] == 'Debian' %}
    - pkgs:
      - php5-fpm 
      - php5-gd 
      - php5-imap 
      - php5-mysql 
      - php5-soap 
      - php5-xml 
      - php5-pdo
      - php5-mcrypt
      - php5-mbstring
  {% endif %}

  {% if grains['os_family'] == 'RedHat' %}
  file.managed:
    - name: /etc/php-fpm.conf
    - source: salt://arquivos/php-fpm/php-fpm.conf_centos
  
    - name: /etc/php.ini
    - source: salt://arquivos/php-fpm/php.ini

    - name: /etc/php-fpm.d/www.conf
    - source: salt://arquivos/php-fpm/www.conf

  {% elif grains['os_family'] == 'Debian' %}
  file.managed: 
    - name: /etc/php5/fpm/php-fpm.conf
    - source: salt://arquivos/php-fpm/php-fpm.conf_ubuntu

    - name: /etc/php5/fpm/php.ini
    - source: salt://arquivos/php-fpm/php.ini

    - name: /etc/php5/fpm/pool.d/www.conf
    - source: salt://arquivos/php-fpm/www.conf
  {% endif %}

  service.running:
  {% if grains['os_family'] == 'RedHat' %}
    - name: php-fpm
  {% elif grains['os_family'] == 'Debian' %}
    - name: php5-fpm
  {% endif %}
    - enable: True

  cmd.run: 
    - names: 
      - mkdir -p /var/lib/php/session
      - chown nginx.nginx -R /var/lib/php/

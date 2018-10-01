include: 
  - nginx_repo
  - sysctl_conf

nginx: 
#  pkgrepo.managed:
#  {% if grains['os_family'] == 'Debian' %}
#    - humanname: NGinx PPA
#    - name: deb http://nginx.org/packages/ubuntu/ trusty nginx
#    - dist: trusty 
#    - file: /etc/apt/sources.list.d/nginx.list
#    - key_url: https://nginx.org/keys/nginx_signing.key
#  {% endif %}

  pkg.installed:
    - name: nginx

  service.running:
    - name: nginx
    - enable: True

  file.recurse:
    - name: /etc/nginx
    - source: salt://arquivos/nginx
    - user: root
    - group: root

  cmd.run: 
    - names: 
      - mkdir -p /var/lib/nginx/cache
      - chown nginx.nginx /var/lib/nginx 

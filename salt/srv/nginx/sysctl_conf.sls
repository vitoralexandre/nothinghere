sysctl_conf:
  file.managed:
    - name: /etc/sysctl.conf
    - source: salt://arquivos/sysctl.conf
    - user: root
    - group: root
    - mode: 644

  cmd.run:
    - name: sysctl -p /etc/sysctl.conf

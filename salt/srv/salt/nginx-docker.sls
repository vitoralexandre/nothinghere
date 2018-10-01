nginx: 
  docker_container.run:
    - name: nginx
    - image: centos:latest
    - cap_add:
      - SYS_ADMIN
      - NET_ADMIN
    - entrypoint: "/usr/sbin/init"
    - detach: True
    - domainname: passeidireto
    - environment:
      - TZ: America/Sao_Paulo 
    - hostname: nginx.passeidireto 
    - interactive: True 
    - log_driver: syslog 
    - mem_limit: 1G 
    - restart: unless-stopped 
    - networks:
      - macvlan:
        - ipv4_address: 172.16.0.20
    - sysctls:
      - net.ipv4.conf.all.accept_redirects=0
      - net.ipv4.conf.all.accept_source_route=0
      - net.ipv4.conf.all.log_martians=1
      - net.ipv4.conf.all.rp_filter=1
      - net.ipv4.conf.all.secure_redirects=0
      - net.ipv4.conf.all.send_redirects=0
      - net.ipv4.conf.default.accept_redirects=0
      - net.ipv4.conf.default.accept_source_route=0
      - net.ipv4.conf.default.accept_source_route=0
      - net.ipv4.conf.default.log_martians=1
      - net.ipv4.conf.default.rp_filter=1
      - net.ipv4.conf.default.rp_filter=1
      - net.ipv4.conf.default.secure_redirects=0
      - net.ipv4.conf.default.send_redirects=0
      - net.ipv4.icmp_echo_ignore_broadcasts=1
      - net.ipv4.icmp_ignore_bogus_error_responses=1
      - net.ipv4.ip_forward=1
      - net.ipv4.ip_local_port_range=2000 65000
      - net.ipv4.tcp_fin_timeout=5
      - net.ipv4.tcp_rmem=4096 87380 8388608
      - net.ipv4.tcp_syncookies=0
      - net.ipv4.tcp_timestamps=0
    - binds: 
      - /sys/fs/cgroup:/sys/fs/cgroup:ro 

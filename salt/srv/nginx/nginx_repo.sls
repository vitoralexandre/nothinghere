nginx_repo: 
  file.managed: 
    - name: /etc/yum.repos.d/nginx.repo
    - source: salt://arquivos/nginx.repo

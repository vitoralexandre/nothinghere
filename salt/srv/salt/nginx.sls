/etc/nginx/conf.d/default.conf: 
  file.managed: 
    - source: 
      - salt://arquivos/default.conf

nginx-actions: 
  cmd.run: 
    - names: 
      - nginx -t && nginx -s reload

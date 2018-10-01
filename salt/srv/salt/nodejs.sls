nodejs:
  pkg.installed:
    - pkgs: 
      - npm
      - mysql

  service.running:
    - name: npm
    - enable: True
  
  cmd.run:
    - names:
      - mkdir -p /virtual/app
      - npm install pm2@latest -g

  file.recurse:
    - name: /virtual/app
    - source: salt://arquivos/PasseiDireto/CodFonte
    - user: root
    - group: root

/lib/systemd/system/serverjs.service:
  file.managed:
    - source:
      - salt://arquivos/PasseiDireto/serverjs.service

app:
  cmd.run:
    - cwd: /virtual/app
    - names:
      - mysql -h 172.16.0.21 -u notes-api -p$(grep password /virtual/app/server.js  | awk -F"'" '{print $2}') notes < /virtual/app/database_schema.sql
      - npm install --save 
      - systemctl daemon-reload
      - systemctl enable serverjs 
      - systemctl start serverjs

codupdate: 
  file.recurse:
    - name: /virtual/app
    - source: salt://arquivos/PasseiDireto/CodFonte
    - user: root
    - group: root

  cmd.run:
    - cwd: /virtual/app
    - names:
      - npm install --save
      - systemctl stop serverjs
      - systemctl start serverjs
~                                

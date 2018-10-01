# Passei Direto 

Oportunidade Passei Direto 
- Rede MacVlan
- Servidor SaltStack
- Servidor NGinx com balanceamento de carga
- Servidor MySQL 
- Servidor NodeJS

## Baixando o repositóio GIT
```
git clone https://github.com/vitoralexandre/nothinghere.git
cd nothinghere
```

## Rede MacVlan 
``` 
docker network  create  -d macvlan --subnet=172.16.0.0/24 --gateway=172.16.0.254 -o parent=enp1s0 -o ipvlan_mode=l2 macvlan
```

## Servidor SaltStack 
### Criação do Container
```
docker run -d --cpus=1 -m=1g -it --cap-add=SYS_ADMIN --cap-add=NET_ADMIN -v /sys/fs/cgroup:/sys/fs/cgroup:ro --network=macvlan --ip=172.16.0.29 --restart unless-stopped -h salt  --name=salt  centos /usr/sbin/init
```
### Instalação do SaltStack Master (Servidor) 
```
docker exec -it salt bash 
```

Dentro do container, vamos executar os seguints passos: 

**1** ``` yum update -y ``` 

O SaltStack possui um instalador multi-plataforma disponível, o qual procede com as devidas instalações de forma mais fácil, evitando a necessidade de adição de repositórios. 

**2** ``` curl -L https://bootstrap.saltstack.com -o install_salt.sh ``` 

O SaltStack possui um instalador multi-plataforma disponível, o qual procede com as devidas instalações de forma mais fácil, evitando a necessidade de adição de repositórios. 

**3** ``` sh install_salt.sh -P -M ```

Vamos adicionar um usuário para que, caso desejado, possa ser utilizada a API do SaltStack

**4** ``` useradd salt ```

Definindo uma senha: 

**5** ``` passwd salt ```

Vamos instalar a API: 

**6** ``` yum install -y salt-api ```

Agora vamos adicionar os serviços no boot: 

**7** ``` systemctl enable salt-master  ```

**8** ``` systemctl enable salt-api ``` 

### Configuração
Agora vamos copiar os arquivos que baixamos do GIT para configuração do salt-master e salt-api.

Saia do container e siga os passos abaixo: 

* Lembrando que já estamos dentro do diretório do repositório baixado, conforme instruções no começo deste tutorial. 

**1** ``` docker cp salt/etc/salt/master salt:/etc/salt/ ``` 

Agora vamos reiniciar o salt-master e o salt-api para ativar as mudanças que fizemos nos arquivos. 

**2** ``` docker exec -it salt systemct restart salt-master ```

**3** ``` docker exec -it salt systemct restart salt-api ```

Agora vamos copiar os states para o container: 

**4** ``` docker cp salt/srv salt:/ ```

Tudo feito! 
Agora vamos aos demais passos! ;) 

## Instalando o salt-minion 

Para começarmos a utilizar o SaltStack, podemos utilizar as opção do Minion (agente) ou SSH. 

Desta vez, optei por utilizar o salt-minion. Vamos à instalação do mesmo no servidor dos containers. 

**1** ``` curl -L https://bootstrap.saltstack.com -o install_salt.sh ```

**2** ``` sh install_salt.sh -P ```

Configurando o minion:

**3** ```cat salt/minion/minion > /etc/salt/minion``` 

Adicionando o serviço no boot e reiniciando o mesmo para colocar as alterações em produção. 

**4** ```systemctl enable salt-minion```

**5** ```systemctl restart salt-minion```

- Pelas configurações realizadas no salt-master, não é necessário aceitar os minion, já que há um auto-accept. Se fosse necessário aceitar manualmente, bastaria executar os seguintes comandos: 

**1** Listando as chaves não aceitas:

```salt-key -l unaccepted```

**2** Aceitando a chave:

```salt-kel -a CHAVEDOMINION``` 

## Servidor NGinx com balanceamento de carga

Entre no containter do SaltStack com: 

```docker exec -it salt bash```

- Criando o container do NGinx: 

```salt huginemunin.dockerserver state.apply nginx-docker```

- Algumas ações serão necessárias para que possamos integrar o SaltStack, vamos aos passos: 

**1** ```salt huginemunin.dockerserver docker.run nginx 'yum update -y'```

**2** ```salt huginemunin.dockerserver docker.run nginx 'yum install epel-release -y'```

**3** ```salt huginemunin.dockerserver docker.run nginx 'yum install python2-pip.noarch -y'```

**4** ```salt huginemunin.dockerserver docker.run nginx 'pip install --upgrade pip'```

**5** ```salt huginemunin.dockerserver docker.run nginx 'pip install futures'```

- Agora vamos instalar e configurar o NGinx de acordo com o state que criamos.

```salt huginemunin.dockerserver dockerng.sls nginx saltenv='nginx' mods=nginx```

- Vamos fazer o update do default.conf para responder às nossas espectativas com relação ao balanceamento de carga: 

```salt huginemunin.dockerserver dockerng.sls nginx mods=nginx```

- Uma informação importante é que, caso deseje criar uma novo container, é importante editar os seguintes arquivos:

/srv/salt/arquivos/default.conf --> Adicionar os novos servidores e executar ``salt huginemunin.dockerserver dockerng.sls nginx saltenv='nginx' mods=nginx```

## Servidor MySQL

Ainda dentro do containter do SaltStack, salt, vamos executar os seguintes comandos: 

- Criando o containers do MySQL: 
```salt huginemunin.dockerserver state.apply mysql-docker```

- Vamos proceder comas instalações para integração do SaltStack como fizemos no NGinx: 

**1** ```salt huginemunin.dockerserver docker.run mysql 'yum update -y'```

**2** ```salt huginemunin.dockerserver docker.run mysql 'yum install epel-release -y'```

**3** ```salt huginemunin.dockerserver docker.run mysql 'yum install python2-pip.noarch -y'```

**4** ```salt huginemunin.dockerserver docker.run mysql 'pip install --upgrade pip'```

**5** ```salt huginemunin.dockerserver docker.run mysql 'pip install futures'``` 

- Agora vamos instalar e configurar o MySQL (o Percona foi a escolha) de acordo com o state que criamos.

```salt huginemunin.dockerserver dockerng.sls mysql saltenv='mysql' mods=mysql```

- Proceda com a configuração do MySQL (mysql-sercure-installation): 

```salt huginemunin.dockerserver docker.run mysql 'bash /root/configure_mysql.sh'```

Ele fará toda a configuração e gerará uma senha para o usuário root. 

Agora vamos a criação da base e do usuário para conexão da aplicação. 

Entre no containter com ```docker exec -it mysql bash``` e execute:

```
[root@mysql /]# mysql -p$(cat /root/.mysqlpasswd) -e "create database notes;"
Warning: Using a password on the command line interface can be insecure.
[root@mysql /]# mysql -p$(cat /root/.mysqlpasswd) -e "show databases;"
Warning: Using a password on the command line interface can be insecure.
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| notes              |
| performance_schema |
+--------------------+
[root@mysql /]# mysql -p$(cat /root/.mysqlpasswd) -e "create user 'notes-api'@'%' identified by 'yWRsbyr7MTMjdUhG';"
Warning: Using a password on the command line interface can be insecure.
[root@mysql /]# mysql -p$(cat /root/.mysqlpasswd) -e "grant all privileges on notes.* to 'notes-api'@'%'"
Warning: Using a password on the command line interface can be insecure.
[root@mysql /]# mysql -p$(cat /root/.mysqlpasswd) -e "flush privileges"
Warning: Using a password on the command line interface can be insecure.
[root@mysql /]# mysql -p$(cat /root/.mysqlpasswd) -e "show grants for 'notes-api'@'%'"
Warning: Using a password on the command line interface can be insecure.
+----------------------------------------------------------------------------------------------------------+
| Grants for notes-api@%                                                                                   |
+----------------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO 'notes-api'@'%' IDENTIFIED BY PASSWORD '*9761C8A40E3FF5D053CFE78872F884878D43DEED' |
| GRANT ALL PRIVILEGES ON `notes`.* TO 'notes-api'@'%'                                                     |
+----------------------------------------------------------------------------------------------------------+
[root@mysql /]# 
```

## Servidor NodeJS
*.
Agora, com o NGinx e o MySQL configurados, vamos ao servidor da aplicação. 

- Criando o container do NodeJS: ```salt huginemunin.dockerserver state.apply node-docker```

- Vamos proceder comas instalações para integração do SaltStack como fizemos para os demais contianers:
**1** ```salt huginemunin.dockerserver docker.run node 'yum update -y'```

**2** ```salt huginemunin.dockerserver docker.run node 'yum install epel-release -y'```

**3** ```salt huginemunin.dockerserver docker.run node 'yum install python2-pip.noarch -y'```

**4** ```salt huginemunin.dockerserver docker.run node 'pip install --upgrade pip'```

Agora vamos instalar o NPM necessário para rodar o NodeJS: 

```salt huginemunin.dockerserver docker.run node 'yum install -y npm'```

Feito isto, vamos executar o state que vai enviar os arquivos da aplicação, fazer a importação das tabelas e criar um daemon para nossa aplicação: 

```salt huginemunin.dockerserver dockerng.sls node mods=nodejs```

Pronto! Seu servidor já está funcionando. 

## Informações adicionais 

O NGinx está ativo para fazer balanceamento de carga, portanto, caso deseje criar um novo servidor NodeJS, basta proceder da seguinte forma: 

**1** Edite o arquivo /srv/salt/node-docker.sls modificando as seguintes linhas: 

- name: node

- hostname: node.passeidireto

- ipv4_address: 172.16.0.23

Estes campos sãp importantes para identificação no docker (name), identificação quando estiver conectado no container (hostname) e configuração do NGinx (ipv4_address). 

**2** Edite o arquivo /srv/salt/arquivos/default.conf adicionando a linha: 

server 172.16.0.XXX:8080; 

Onde XXX é o último octeto do IP do container. 

**3** Execute o state de update da configuração do NGinx: 

```salt huginemunin.dockerserver dockerng.sls nginx mods=nginx```



Também podemos atualizar os arquivos de código fonte facilmente com o seguinte state: 

```salt huginemunin.dockerserver dockerng.sls node mods=codupdate```

Para isto, basta editar os arquivos que estão em /srv/salt/arquivos/PasseiDireto/CodFonte/ . 

 

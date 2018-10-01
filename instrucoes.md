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

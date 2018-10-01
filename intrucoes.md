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
Sai do container e siga os passos abaixo: 
**1** 

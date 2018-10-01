mysql_repo:
{% if grains['os_family'] == 'RedHat' %}
  pkg.installed:
    - sources: 
      - percona: https://www.percona.com/redir/downloads/percona-release/redhat/latest/percona-release-0.1-6.noarch.rpm

{% elif grains['os_family'] == 'Debian' %}
  pkg.installed:
    - sources: 
      - percona: https://repo.percona.com/apt/percona-release_0.1-6.$(lsb_release -sc)_all.deb
{% endif %}


  cmd.run:  
    - names: 
      - yum update -y 

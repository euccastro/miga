#!/usr/bin/env bash

# Este script configura o servidor como um mestre e escravo de Salt
# (http://saltstack.org) que recebe a configuraçom dum repositório de git.
#
# É necessário configurá-lo como mestre porque (que eu saiba) um nodo de Salt
# sem mestre (masterless) nom pode obter a configuraçom de git.  Além disso,
# este servidor pode ficar de mestre para levantar quaisquer outras máquinas
# que precisarmos.
#
# Aqui só configuramos o imprescindível para aceder ao repositório.

mkdir -p /tmp/salt
LOG=/tmp/salt/bootstrap.log

apt-get install python-software-properties git python-pip build-essential python-dev ufw -y > >(tee -a $LOG) 2>&1

# Anovamos pip aginha, porque versons velhas tenhem problemas de segurança.
pip install --upgrade pip
pip install gitpython > >(tee -a $LOG) 2>&1

# O servidor vai aceitar todas as chaves que lhe enviem (ver "auto_accept: yes"
# embaixo).  Para que nom nos metam chaves de fóra, ativamos o guarda-fogo
# (firewall), permitindo apenas o porto de SSH, por se houver que entrar
# a amanhar algũa cousa.
#
# A configuraçom de salt que baixamos do repositório deveria estabelecer ũa
# configuraçom definitiva para o guarda-fogo.
echo y | ufw reset --force
ufw allow openssh
echo y | ufw enable

NOME_HOST=miga-amo
# Configuramos o nome de host aqui para nom ter que anovar as chaves despois.
echo $NOME_HOST > /etc/hostname
hostname -F /etc/hostname

# Engadimos hostname e máis alias 'salt', empregado polo minion de Salt.
sed -i "s/^127.0.0.1.*$/127.0.0.1 $NOME_HOST localhost salt/" /etc/hosts

# Partimos dum estado conhecido se nom é a primeira vez que corremos o script
# (por exemplo, provando nũa máquina nova), e evitamos que apt-get nos
# pergunte o que fazer coa configuraçom existente.
rm -rf /etc/salt

add-apt-repository ppa:saltstack/salt -y > >(tee -a $LOG) 2>&1
apt-get update -y > >(tee -a $LOG) 2>&1
apt-get install salt-master -y > >(tee -a $LOG) 2>&1

mkdir -p /etc/salt
touch /etc/salt/minion
echo "auto_accept: yes" > /etc/salt/master
echo "fileserver_backend: ['git']" >> /etc/salt/master
echo "gitfs_remotes: ['git://github.com/euccastro/miga-salt.git']" >> /etc/salt/master

service salt-master restart > >(tee -a $LOG) 2>&1
apt-get install salt-minion -y > >(tee -a $LOG) 2>&1
service salt-minion stop > >(tee -a $LOG) 2>&1

salt-call state.highstate > >(tee -a $LOG) 2>&1

# A própria configuraçom de Salt deveria garantir isto, pero para estarmos
# certos...
service salt-minion start > >(tee -a $LOG) 2>&1

echo "Salt levantado!" > >(tee -a $LOG) 2>&1

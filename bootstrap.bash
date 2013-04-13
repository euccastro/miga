#!/usr/bin/env bash

# Configura a máquina onde este script corre como um master e minion de Salt
# (http://saltstack.org).  Quando correres isto, os arquivos de estado devem
# ter sido subidos a /srv/salt.

HOSTNAME=miga

export DEBIAN_FRONTEND=noninteractive

LOG=/tmp/salt-bootstrap.log

# Engade o local que usares para evitar avisos de perl.
locale-gen en_US en_US.UTF-8 gl_ES.UTF-8
dpkg-reconfigure locales

# Configuramos o nome do host antes de gerar as chaves de salt para termos
# a configuraçom correta desde já e nom termos que anovar as chaves de salt
# despois.
echo $HOSTNAME > /etc/hostname
hostname -F /etc/hostname

# O alias 'salt' é para o minion encontrar o master local.
sed -i "s/^127.0.0.1.*$/127.0.0.1 $HOSTNAME localhost salt/" /etc/hosts

apt-get install python-software-properties -y > >(tee -a $LOG) 2>&1
add-apt-repository ppa:saltstack/salt -y > >(tee -a $LOG) 2>&1
apt-get update -y > >(tee -a $LOG) 2>&1
apt-get upgrade -y > >(tee -a $LOG) 2>&1
apt-get autoremove -y > >(tee -a $LOG) 2>&1
service salt-minion stop
service salt-master stop
apt-get purge salt-master -y > >(tee -a $LOG) 2>&1
apt-get purge salt-minion -y > >(tee -a $LOG) 2>&1
rm -rf /etc/salt
apt-get install salt-master -y > >(tee -a $LOG) 2>&1
apt-get install salt-minion -y > >(tee -a $LOG) 2>&1

while [ ! -e /etc/salt/pki/master/minions_pre/$HOSTNAME ]
do
    echo "Chave nom preaceitada ainda, aguardando..." > >(tee -a $LOG) 2>&1
    sleep 1
done

# Asseguramo-nos de aceptar a chave local.
rm /etc/salt/pki/master/minions_pre/$HOSTNAME
cp /etc/salt/pki/minion/minion.pub /etc/salt/pki/master/minions/$HOSTNAME

echo "Salt configurado." > >(tee -a $LOG) 2>&1

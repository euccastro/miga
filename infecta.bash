#!/usr/bin/env bash

# Inicializa o servidor na IP que lhe damos para que funcione como um
# amo/escravo de Salt coa configuraçom no repositório miga-salt.
#
# Hai que usá-lo co utente de ssh root ou que tenha sudo sem contrasinal.
#
# Para nom ter que andar tecleando o IP, e enquanto nom termos um domínio
# apontando a essa máquina, é recomendado ter um alias para ela em
# /etc/hosts .
#
# Exemplo: ./infecta.bash root@miga

if [ $1 ]
then
    MIGA=$1
fi

if [ -z $MIGA ]
then
    echo "Uso: $0 <endereço>"
    exit 1
fi

scp bootstrap.bash $MIGA:
ssh $MIGA "sudo ./bootstrap.bash"
./anova.bash $MIGA

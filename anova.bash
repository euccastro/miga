#!/usr/bin/env bash

# Anova a configuraçom do servidor com respeito à do repo miga-salt.
#
# Hai que usá-lo com root ou com um utente que tenha sudo sem contrasinal.
#
# Exemplo: ./anova.bash es@mancomunidadeintegralgalega.net

if [ -z $1 ]
    then
        echo "Uso: $0 <endereço>"
        exit 1
fi
LOGFILE=$(dirname $0)/anova.log
echo > $LOGFILE
rsync -azLk salt/ $1:salt > >(tee -a $LOGFILE) 2>&1
ssh $1 "sudo rm -rf /srv/salt" > >(tee -a $LOGFILE) 2>&1
ssh $1 "sudo cp -r salt /srv/salt" > >(tee -a $LOGFILE) 2>&1
ssh $1 "sudo salt-call state.highstate" > >(tee -a $LOGFILE) 2>&1

echo "Erros:"
grep -i error $LOGFILE
grep False $LOGFILE
echo "/Erros"

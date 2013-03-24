#!/usr/bin/env bash

# Inicializa o servidor na IP que lhe damos

if [ -z $1 ]
    then
        echo "Uso: $0 <endereço>"
        exit 1
fi

scp bootstrap.bash $1:
ssh $1 "sudo ./bootstrap.bash"

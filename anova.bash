#!/usr/bin/env bash

# Anova a configuraçom do servidor com respeito à do repo miga-salt.

if [ -z $1 ]
    then
        echo "Uso: $0 <endereço>"
        exit 1
fi

ssh $1 "sudo salt '*' state.highstate"

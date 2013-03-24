#!/usr/bin/env bash

# Script para provar amanhos no repositório miga-salt.  Inclue um tempo de
# espera porque o salt-master do servidor demora em apanhar as mudanças do
# repo git.
git commit -am "$*"
git push
echo "Esperando para provar..."
sleep 7
echo "Provando!"
$(dirname $0)/anova.bash miga
echo "Feito."

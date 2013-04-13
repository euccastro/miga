#!/usr/bin/env bash

VERSION=2.6.11

wget -q https://redis.googlecode.com/files/redis-$VERSION.tar.gz
tar zxvf redis-$VERSION.tar.gz
mv redis-$VERSION src
cd src
make

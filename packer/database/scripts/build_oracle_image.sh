#!/usr/bin/env bash

cd $PWD/db/docker-images-master/OracleDatabase/SingleInstance/dockerfiles/
./buildDockerImage.sh -v 12.2.0.1 -e
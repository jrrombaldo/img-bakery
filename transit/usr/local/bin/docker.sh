#!/usr/bin/env bash

/usr/local/bin/strict.sh

curl -sSL https://get.docker.com | sh
sudo usermod -a -G docker pi

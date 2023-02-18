#!/usr/bin/env bash


while ! ping -c 1 192.168.0.250 &> /dev/null; do sleep 1; done
sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 admin@192.168.0.250:/ ~/mnt/Server

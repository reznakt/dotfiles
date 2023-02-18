#!/usr/bin/env bash


if command -v apt-fast &> /dev/null; then
	APTCMD="apt-fast"
else
	APTCMD="apt"
fi


. sclib

scset "SCERR"
scset "SCDEBUG"
. scinit


sudo $APTCMD update -y
sudo $APTCMD full-upgrade -y
sudo $APTCMD autoremove -y
sudo $APTCMD clean -y
sudo $APTCMD autoclean -y


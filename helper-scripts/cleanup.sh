#!/bin/bash
#V0.0.9 - Beta

# load in configuration variables
. config-temp.conf

#General cleanup

rm -f $weatherdir/*
rm -r $workdir/*

./autoupdate.sh

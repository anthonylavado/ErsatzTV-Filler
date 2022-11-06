#!/bin/bash
#V0.0.17 - Beta

# load in configuration variables
. config-temp.conf

#General cleanup

echo "Stating clean up"

rm -f $weatherdir/*
rm -r $workdir/*
rm -f $scriptdir/running.txt
echo "Finished cleaning up"
exit 0

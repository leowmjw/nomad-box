#!/bin/bash
#

ulimit -n 8192 && sudo ./caddy &

node ./bonjour.js & 
# http://stackoverflow.com/questions/1908610/how-to-get-pid-of-background-process
BONJOUR_PID=$!
echo "BONJOUR is runnning PID ${BONJOUR_PID}"


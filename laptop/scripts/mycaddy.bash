#!/bin/bash
#

ulimit -n 8192 && ./caddy &

node ./bonjour.js 


#!/bin/sh

# run init
/init-heimdal.sh

kadmind --detach
kdc --address=0.0.0.0

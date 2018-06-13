#!/bin/sh

# run init
/init-krb5.sh

kadmind
krb5kdc -n

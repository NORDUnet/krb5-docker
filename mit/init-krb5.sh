#!/bin/sh

# Check if init-krb5 has already been run
KRB5_DIR=/var/lib/krb5kdc
DOCKER_DONE=$KRB5_DIR/docker-done
if [ ! -f "$DOCKER_DONE" ]; then

  if [ -z "$DOMAIN" ]; then
    DOMAIN=$(echo "$REALM" | tr '[:upper:]' '[:lower:]')
  fi
  sed -i -e "s/EXAMPLE.COM/$REALM/" -e "/default_realm/ s/=.*/= $REALM/" -e "/default_domain/ s/=.*/= $DOMAIN/" /etc/krb5.conf
  sed -i -e "s/EXAMPLE.COM/$REALM/"  "$KRB5_DIR/kdc.conf"
  sed -i -e "s/EXAMPLE.COM/$REALM/"  "/opt/krb5/kadm5.acl"

  kdb5_util create -r "$REALM" -s -P SuperSecretPassword

  kadmin.local -q "add_principal -randkey adminuser/admin"
  mkdir -p /opt/keytabs
  rm /opt/keytabs/*-keytab
  for pair in ${PRINCIPALS}; do
    principal=$(echo "$pair" | awk -F: '{print $1}')
    passwd=$(echo "$pair" | awk -F: '{print $2}')
    if [ -n "$passwd" ]; then
      kadmin.local -q "add_principal -pw $passwd  $principal"
    else
      kadmin.local -q "add_principal -randkey  $principal"
    fi
    kadmin.local -q "ktadd -norandkey -k /opt/keytabs/$principal-keytab $principal"
  done
  touch "$DOCKER_DONE"
fi

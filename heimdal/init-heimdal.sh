#!/bin/sh

# Check if init-krb5 has already been run
HEIMDAL_DIR=/var/heimdal
DOCKER_DONE=$HEIMDAL_DIR/docker-done

# Everytime
if [ -f /opt/heimdal/kadmind.acl ]; then
  cp /opt/heimdal/kadmind.acl "$HEIMDAL_DIR/"
else
  sed -i -e "s/EXAMPLE.COM/$REALM/g" $HEIMDAL_DIR/kadmind.acl
fi

# Only first time
if [ ! -f "$DOCKER_DONE" ]; then
  mkdir -p "$HEIMDAL_DIR"

  if [ -z "$DOMAIN" ]; then
    DOMAIN=$(echo "$REALM" | tr '[:upper:]' '[:lower:]')
  fi
  sed -i -e "s/EXAMPLE.COM/$REALM/" -e "/default_realm/ s/=.*/= $REALM/" -e "/default_domain/ s/=.*/= $DOMAIN/" /etc/krb5.conf

  if ! grep -q "\[kdc\]" /etc/krb5.conf; then
    echo -e "[kdc]\n  database = {\n    acl_file = /opt/heimdal/kadmind.acl\n  }" >> /etc/krb5.conf
  fi

  kstash --random-key
  kadmin -l init --realm-max-ticket-life=unlimited --realm-max-renewable-life=unlimited "$REALM"

  mkdir -p /opt/keytabs
  rm /opt/keytabs/*.keytab
  for pair in ${PRINCIPALS}; do
    principal=$(echo "$pair" | awk -F: '{print $1}')
    passwd=$(echo "$pair" | awk -F: '{print $2}')
    if [ -n "$passwd" ]; then
      kadmin -l add --use-defaults -p "$passwd" "$principal@$REALM"
    else
      kadmin -l add --use-defaults  --random-password "$principal@$REALM"
    fi
    kadmin -l ext_keytab -k "/opt/keytabs/$principal.keytab" "$principal@$REALM"
  done
  touch "$DOCKER_DONE"
fi

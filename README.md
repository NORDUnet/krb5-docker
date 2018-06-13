# Kerberos for testing

A quick and easy docker image for testing against a kerberos. Comes in two flavors MIT kerberos and heimdal.


## Building

```
# MIT kerberos
$ docker build -f Dockerfile.mit -t krb5-alpine .

# Heimdal
$ docker build -f Dockerfile.heimdal -t heimdal-alpine .
```


## Running

```
$ docker run --rm -ti -p 127.0.0.1:8888:88 -p 127.0.0.1:7749:749 -v $(pwd)/keytabs:/opt/keytabs -e PRINCIPALS="pwman:pwmantest markus:test" -e REALM=NORDU.NET krb5-alpine

$ docker run --rm -ti -p 127.0.0.1:8888:88 -p 127.0.0.1:7749:749 -v $(pwd)/keytabs:/opt/keytabs -e PRINCIPALS="pwman:pwmantest markus:test" -e REALM=NORDU.NET heimdal-alpine
```

## Environment varables

- `PRINCIPALS` a space seperated string defining principals to create. For random password just skip the `:password`. e.g. `markus/admin:pwmantest markus` Defaults to `pwman:pwmantest` 
- `REALM` the realm to use defaults to `EXAMPLE.COM`

## Other config

- The acl is done in  `/opt/heimdal/kadmind.acl` or `/opt/krb5/kadm5.acl`. Changes to `kadmincd.acl` in heimdal requires container restart.
- `/etc/krb5.conf` default kerberos config
- `/var/lib/krb5kdc/kdc.conf` MIT KDC config

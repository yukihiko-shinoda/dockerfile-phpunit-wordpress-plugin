#!/usr/bin/env sh
SERVERCERT="/etc/pki/tls/certs/servercert-${DOMAIN_NAME}.pem"
SERVERKEY="/etc/pki/tls/private/serverkey-${DOMAIN_NAME}.pem"
while :; do
    if [ -r "${SERVERCERT}" ]; then
        break
    fi
    sleep 1
done

group_database=$([ $(which postgres) ] && echo "postgres" || echo "mysql")

chown "root:${group_database}" "${SERVERKEY}"
chmod 640 "${SERVERKEY}"
# "docker-entrypoint.sh" is default ENTRYPOINT of Docker Hub official database images.
# see: https://github.com/docker-library/mysql/blob/8e6735541864ab63c98cdf92d3ef498e4c953f3e/8.0/Dockerfile
# see: https://github.com/docker-library/mysql/blob/8e6735541864ab63c98cdf92d3ef498e4c953f3e/5.7/Dockerfile
# see: https://github.com/docker-library/mysql/blob/8e6735541864ab63c98cdf92d3ef498e4c953f3e/5.6/Dockerfile
# see: https://github.com/docker-library/postgres/blob/b80fcb5ac7f6dde712e70d2d53a88bf880700fde/Dockerfile-debian.template
# see: https://github.com/docker-library/postgres/blob/b80fcb5ac7f6dde712e70d2d53a88bf880700fde/Dockerfile-alpine.template
exec docker-entrypoint.sh "$@"

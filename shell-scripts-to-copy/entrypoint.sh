#!/usr/bin/env bash
set -eu

DOMAIN_NAME=${DOMAIN_NAME-database}
DATABASE_NAME=${DATABASE_NAME-wordpress}
DATABASE_USER=${DATABASE_USER-root}
DATABASE_PASSWORD=${DATABASE_PASSWORD}
DATABASE_HOST=${DATABASE_HOST-database}
DATABASE_PORT=${DATABASE_PORT-3306}
WORDPRESS_VERSION=${WORDPRESS_VERSION-latest}

SERVERCERT="/etc/pki/tls/certs/servercert-${DOMAIN_NAME}.pem"
SERVERKEY="/etc/pki/tls/private/serverkey-${DOMAIN_NAME}.pem"
while :; do
    if [ -r "${SERVERCERT}" ]; then
        break
    fi
    sleep 1
done

cp -p /etc/pki/CA/cacert-${DOMAIN_NAME}.pem /usr/local/share/ca-certificates/cacert-${DOMAIN_NAME}.crt
update-ca-certificates

# Sometimes, timeout occurred when set 45 seconds for MySQL 8
wait-for-it --timeout=90 "${DATABASE_HOST}:${DATABASE_PORT}" -- install-wp-tests "${DATABASE_NAME}" "${DATABASE_USER}" "${DATABASE_PASSWORD}" "${DATABASE_HOST}:${DATABASE_PORT}" "${WORDPRESS_VERSION}"
exec "${@}"

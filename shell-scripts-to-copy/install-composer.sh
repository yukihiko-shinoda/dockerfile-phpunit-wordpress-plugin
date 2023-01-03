#!/usr/bin/env bash
# To realize conditional install since Composer 2.3.0 dropped support for PHP <7.2.5.
# PHP Official image isn't installed Python, we have to use Shell Script.
set -eux
source vercomp.sh
PHP_VERSION=${PHP_IMAGE_TAG%%-*}
set +e
vercomp "${PHP_VERSION}" '7.2.5'
COMPOSER_VERSION_CONSTRAINT=$([ "${?}" == 2 ] && echo '2.2.18' || echo '2.4.4')
set -e
# ↓ @see https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
sh -c "wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --version=${COMPOSER_VERSION_CONSTRAINT} --quiet"
mv ./composer.phar /bin/composer

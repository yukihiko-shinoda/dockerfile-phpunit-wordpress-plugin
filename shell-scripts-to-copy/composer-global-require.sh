#!/usr/bin/env bash
# To realize conditional install:
# - Due to mockery/mockery doesn't manage correct dependencies.
# - To install specific version of PHPUnit for testing old WordPress version:
#   - PHPUnit Compatibility and WordPress Versions – Make WordPress Core
#     https://make.wordpress.org/core/handbook/references/phpunit-compatibility-and-wordpress-versions/
# PHP Official image isn't installed Python, we have to use Shell Script.
set -eux
source vercomp.sh
PHP_VERSION=${PHP_IMAGE_TAG%%-*}
set +e
vercomp "${PHP_VERSION}" '8.0.0'
MOCKERY_VERSION_CONSTRAINT=$([ "${?}" == 2 ] && echo '1.3.*' || echo '*')
set -e
PHP_UNIT_VERSION=$([ "${PHP_UNIT_VERSION}" ] && echo "${PHP_UNIT_VERSION}" || echo '<10.0.0')
# ↓ Composer (2.2 or more) will now prompt you the first time you use a plugin
# ↓ to be sure that no package can run code during a Composer run if you do not trust it.
# ↓ @see: https://blog.packagist.com/composer-2-2/
composer global config --no-interaction --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
# phpunit/phpunit:
#   2020-08-24 WordPress supports PHPUnit 9.x
#   @see https://make.wordpress.org/core/handbook/references/php-compatibility-and-wordpress-versions/
# yoast/phpunit-polyfills:
#   2020-11-23 WordPress started to require when running PHPUnit from WordPress 5.8.2
# wp-coding-standards/wpcs
# dealerdirect/phpcodesniffer-composer-installer
# phpcompatibility/phpcompatibility-wp
# automattic/vipwpcs:
#   To execute static analysis by PHP_CodeSniffer
# mockery/mockery
#   To use mock some functions of WordPress like "wp_remote_get"
#   Only 1.3.* is allowed since 1.4 or more requires PHPUnit 8.0 or more
composer global require --prefer-dist \
    "phpunit/phpunit:${PHP_UNIT_VERSION}" \
    yoast/phpunit-polyfills \
    wp-coding-standards/wpcs \
    dealerdirect/phpcodesniffer-composer-installer \
    phpcompatibility/phpcompatibility-wp \
    automattic/vipwpcs \
    "mockery/mockery:${MOCKERY_VERSION_CONSTRAINT}"
composer global clear-cache

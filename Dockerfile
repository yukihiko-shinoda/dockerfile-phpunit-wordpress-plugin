ARG PHP_VERSION
FROM php:${PHP_VERSION}-apache-buster
ARG WORDPRESS_VERSION
ARG PHP_VERSION
# ↓ @see https://github.com/docker-library/php/issues/391#issuecomment-346590029
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN apt update \
# ↓ wget                : To set up this image
# ↓ git                 : To install dependency of PHPUnit 5.* at least myclabs/deep-copy
# ↓ subversion          : Dependencies for install-wp-tests.sh
# ↓ default-mysql-client: Dependencies for install-wp-tests.sh
 && apt install -y git wget subversion default-mysql-client \
 && apt clean
RUN sh -c 'wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet' \
 && mv ./composer.phar /bin/composer
# ↓ To make Composer faster
RUN composer global require --prefer-dist hirak/prestissimo \
 && composer global require --prefer-dist \
# ↓ 2019-11-18 WordPress supports PHPUnit 5.x
# ↓ @see https://make.wordpress.org/cli/handbook/plugin-unit-tests/
    phpunit/phpunit:5.* \
# ↓ To execute static analysis by PHP_CodeSniffer
    wp-coding-standards/wpcs \
    dealerdirect/phpcodesniffer-composer-installer \
    phpcompatibility/phpcompatibility-wp \
    automattic/vipwpcs \
# ↓ To use mock some functions of WordPress like "wp_remote_get"
    mockery/mockery \
 && composer global remove hirak/prestissimo \
 && composer global clear-cache
ENV PATH $PATH:/root/.composer/vendor/bin
# ↓ Hot-fix for HTTP status 429 'Too Many Requests' when checkout testing suite in install-wp-tests
# ↓ @see https://wordpress.org/support/topic/too-many-requests-when-trying-to-checkout-plugin/
RUN wget -O /usr/bin/install-wp-tests https://raw.githubusercontent.com/wp-cli/scaffold-command/v2.0.9/templates/install-wp-tests.sh \
# ↓ Hot-fix for install-wp-tests.sh
# ↓ @see https://github.com/wp-cli/scaffold-command/pull/269
 && sed -i "s/if\s\[\s\\\$(mysql\s--user=\"\\\$DB_USER\"\s--password=\"\\\$DB_PASS\"\s--execute='show databases;'\s|\sgrep\s^\\\$DB_NAME\\\$)\s\]/if [ \$(mysql --user=\"\$DB_USER\" --password=\"\$DB_PASS\"\$EXTRA --execute='show databases;' | grep ^\$DB_NAME\$) ]/" /usr/bin/install-wp-tests \
 && sed -i "/read\s-p\s'Are\syou\ssure\syou\swant\sto\sproceed?\s\[y\/N\]:\s'\sDELETE_EXISTING_DB/d" /usr/bin/install-wp-tests \
 && chmod +x /usr/bin/install-wp-tests
# ↓ I decided "for the time being," "yes" may not be definitely better.
ENV DELETE_EXISTING_DB yes
ENV WP_CORE_DIR /usr/src/wordpress/
RUN touch wp-tests-config.php \
 && install-wp-tests '' '' '' localhost "${WORDPRESS_VERSION}" true \
 && rm -f wp-tests-config.php
# ↓ @see http://docs.docker.jp/compose/startup-order.html
RUN wget -O /usr/bin/wait-for-it https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
 && chmod +x /usr/bin/wait-for-it
COPY ./entrypoint.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint
ENV WORDPRESS_VERSION=${WORDPRESS_VERSION}
WORKDIR /plugin
ENTRYPOINT ["entrypoint"]
CMD [ "phpunit" ]

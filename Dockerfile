ARG PHP_IMAGE_TAG
FROM php:${PHP_IMAGE_TAG}
ARG PHP_IMAGE_TAG
ARG WORDPRESS_VERSION
ARG PHP_UNIT_VERSION=
# ↓ @see https://github.com/docker-library/php/issues/391#issuecomment-346590029
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN apt-get update \
# ↓ wget                : To set up this image
# ↓ git                 : To install dependency of PHPUnit 5.* at least myclabs/deep-copy
# ↓ subversion          : Dependencies for install-wp-tests.sh
# ↓ default-mysql-client: Dependencies for install-wp-tests.sh
# ↓ unzip               : Dependencies for install-wp-tests.sh in case when WordPress version is nightly or trunk
 && apt-get install -y --no-install-recommends git wget subversion default-mysql-client unzip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --chmod=755 ./shell-scripts-to-copy/vercomp.sh ./shell-scripts-to-copy/install-composer.sh ./shell-scripts-to-copy/composer-global-require.sh ./
RUN ./install-composer.sh
RUN ./composer-global-require.sh
ENV PATH $PATH:/root/.composer/vendor/bin
# ↓ Hot-fix for HTTP status 429 'Too Many Requests' when checkout testing suite in install-wp-tests
# ↓ @see https://wordpress.org/support/topic/too-many-requests-when-trying-to-checkout-plugin/
RUN wget --progress=dot:giga -O /usr/bin/install-wp-tests https://raw.githubusercontent.com/wp-cli/scaffold-command/v2.2.0/templates/install-wp-tests.sh \
# ↓ Remove confirmation for initialize test database since it stops automated testing
 && sed -i "/read\s-p\s'Are\syou\ssure\syou\swant\sto\sproceed?\s\[y\/N\]:\s'\sDELETE_EXISTING_DB/d" /usr/bin/install-wp-tests \
 && chmod +x /usr/bin/install-wp-tests
# ↓ I decided "for the time being," "yes" may not be definitely better.
ENV DELETE_EXISTING_DB yes
ENV WP_CORE_DIR /usr/src/wordpress/
RUN touch wp-tests-config.php \
 && install-wp-tests '' '' '' localhost "${WORDPRESS_VERSION}" true \
 && rm -f wp-tests-config.php
# ↓ @see http://docs.docker.jp/compose/startup-order.html
RUN wget --progress=dot:giga -O /usr/bin/wait-for-it https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
 && chmod +x /usr/bin/wait-for-it
COPY --chmod=755 ./shell-scripts-to-copy/entrypoint.sh /usr/bin/entrypoint
ENV WORDPRESS_VERSION=${WORDPRESS_VERSION}
WORKDIR /plugin
ENTRYPOINT ["entrypoint"]
CMD [ "phpunit" ]

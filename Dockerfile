FROM wordpress:5.3.2-php7.3-apache
RUN apt update
RUN apt install -y wget
RUN sh -c 'wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet' \
 && mv ./composer.phar /bin/composer
RUN composer global require \
# ↓ 2019-11-18 WordPress supports PHPUnit 5.x
# ↓ @see https://make.wordpress.org/cli/handbook/plugin-unit-tests/
    phpunit/phpunit:5.* \
# ↓ To execute static analysis by PHP_CodeSniffer
    wp-coding-standards/wpcs \
    dealerdirect/phpcodesniffer-composer-installer \
    phpcompatibility/phpcompatibility-wp \
    automattic/vipwpcs
ENV PATH $PATH:/root/.composer/vendor/bin
# ↓ Dependencies for install-wp-tests.sh
RUN apt install -y subversion default-mysql-client
# ↓ Hot-fix for HTTP status 429 'Too Many Requests' when checkout testing suite in install-wp-tests
# ↓ @see https://wordpress.org/support/topic/too-many-requests-when-trying-to-checkout-plugin/
RUN wget -O /usr/bin/install-wp-tests https://raw.githubusercontent.com/wp-cli/scaffold-command/4814acbdf3d7af499530cc1ae1e82f3ed9f12674/templates/install-wp-tests.sh \
 && chmod +x /usr/bin/install-wp-tests
ENV WP_CORE_DIR /usr/src/wordpress/
RUN touch wp-tests-config.php \
 && install-wp-tests '' '' '' localhost 5.3.2 true \
 && rm -f wp-tests-config.php \
 && rm -f /tmp/install-wp-tests.sh
# ↓ @see http://docs.docker.jp/compose/startup-order.html
RUN wget -O /usr/bin/wait-for-it https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
 && chmod +x /usr/bin/wait-for-it
COPY ./entrypoint.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint
WORKDIR /plugin
ENTRYPOINT ["entrypoint"]
CMD [ "phpunit" ]

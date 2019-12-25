# How to build new image

## Steps

### 1. Update following middlewares on Dockerfile to the latest

middleware|check point|release information URL
-|-|-
base image|FROM|[wordpress - Docker Hub](https://hub.docker.com/_/wordpress) (Choose the most detailed tag because it doesn't move)
Composer|RUN sh -c 'wget ...|[How do I install Composer programmatically? - Composer](https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md)
PHPUnit|phpunit/phpunit|[Plugin Unit Tests – WP-CLI — WordPress.org](https://make.wordpress.org/cli/handbook/plugin-unit-tests/#running-tests-locally)
install-wp-tests|RUN wget -O /usr/bin/install-wp-tests ...|[Releases · wp-cli/scaffold-command](https://github.com/wp-cli/scaffold-command/releases)

### 2. Run test on local

```shell script
docker-compose -f docker-compose.test.yml run sut
```

### 3. Commit

### 4. Create Pull Request

### 5. Merge Pull Request

### 6. Push with tag same with base image on latest revision of master branch

EX:

```shell script
git tag 5.3.1-php7.3-apache
git push origin 5.3.1-php7.3-apache
```

Then, new image will automatically built.

## Roadmap

I'm planing to automate updating Dockerfile, committing it, and pushing with tag by GitHub Actions. Because Docker Hub prepares link to revision of GitHub repository for referencing Dockerfile and build context. And Docker hub has not support build args yet.

[Feature request: Build args on docker hub · Issue #508 · docker/hub-feedback](https://github.com/docker/hub-feedback/issues/508)

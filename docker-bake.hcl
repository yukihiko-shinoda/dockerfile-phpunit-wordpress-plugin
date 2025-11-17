variable "DOCKER_TAG" {
}
target "phpunit-wordpress-plugin" {
  tags = [
    "futureys/phpunit-wordpress-plugin:latest",
    "futureys/phpunit-wordpress-plugin:${DOCKER_TAG}",
  ]
}
// To prevent following error when testing `docker buildx bake` in development PC:
//   ERROR: Multi-platform build is not supported for the docker driver.
//   Switch to a different driver, or turn on the containerd image store, and try again.
//   Learn more at https://docs.docker.com/go/build-multi-platform/
target "app-release" {
  inherits = ["phpunit-wordpress-plugin"]
  platforms = ["linux/amd64", "linux/arm64"]
}

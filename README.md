# MakeDevOpsEasy

Make DevOps easy for apps.

This Makefile (combined with the .meta.yml file) makes it easy to:
- Build container images
- Push container images
- Handle releases

## Requirements

- make
- yq

## Usage

```shell

# Build
make build

# Build for MAC
make build BUILD_PLATFORM=linux/arm64    

# Push to container registry
make push

# Release patch
make release-patch

# Release minor
make release-minor

# Release major
make release-major
```

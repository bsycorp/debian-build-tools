#!/bin/bash
DOCKER_CONTENT_TRUST=1 docker build -t "bsycorp/debian-build-tools:1.0.$TRAVIS_BUILD_NUMBER" -t "bsycorp/debian-build-tools:latest" .
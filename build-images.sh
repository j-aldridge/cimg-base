#!/usr/bin/env bash
# Do not edit by hand; please use build scripts/templates to make changes

docker build --file 22.04/Dockerfile -t cimg/base:22.04 -t cimg/base:22.04 --platform linux/amd64 .

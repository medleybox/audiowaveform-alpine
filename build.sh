#!/bin/sh
##########
# Build tags master latest and the version compiled
# Only push the latest tag and version
# Master tag is used for local development of medleybox and built by github
##########

docker build -t ghcr.io/medleybox/audiowaveform-alpine:master  .
docker tag ghcr.io/medleybox/audiowaveform-alpine:master ghcr.io/medleybox/audiowaveform-alpine:latest

# Get version built to tag
AF_VERSION_STRING=$(docker run --rm -it ghcr.io/medleybox/audiowaveform-alpine:master --version)
AF_VERSION=$(echo $AF_VERSION_STRING | egrep -o "([0-9]{1,}\.)+[0-9]{1,}")

docker tag ghcr.io/medleybox/audiowaveform-alpine:master ghcr.io/medleybox/audiowaveform-alpine:$AF_VERSION

docker push ghcr.io/medleybox/audiowaveform-alpine:latest
docker push ghcr.io/medleybox/audiowaveform-alpine:$AF_VERSION

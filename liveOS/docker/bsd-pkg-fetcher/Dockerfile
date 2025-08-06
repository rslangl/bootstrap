FROM alpine:latest

RUN apk add --no-cache wget bash

ENV FREEBSD_VERSION=14.1
ENV ARCH=amd64
ENV PKG_REPO_URL=https://pkg.freebsd.org/FreeBSD:${FREEBSD_VERSION}:release/${ARCH}/latest

COPY packages.txt /packages.txt

WORKDIR /pkg_repo

COPY entrypoint.sh ./

ENTRYPOINT ["bash", "./entrypoint.sh"]

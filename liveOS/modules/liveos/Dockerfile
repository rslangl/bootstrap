FROM debian:bookworm-20250610

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        live-build \
        systemd-sysv \
        sudo \
        curl \
        wget \
        git \
        xorriso \
        squashfs-tools \
        cpio \
        rsync \
        apt-utils \
        gnupg \
        dosfstools && \
    apt-get clean

USER root

WORKDIR /workdir

RUN mkdir /workdir/output

COPY config/ ./config/
COPY entrypoint.sh .

ENTRYPOINT ["bash", "./entrypoint.sh"]


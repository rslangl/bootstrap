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

# RUN lb config \
#   --config /workdir/config \
#   --architectures amd64 \
#   --distribution bookworm \
#   --debian-installer live \
#   --binary-images iso-hybrid \
#   --bootappend-live "boot=live components" \
#   --mirror-bootstrap http://deb.debian.org/debian/ \
#   --mirror-binary http://deb.debian.org/debian/ \
#   --image-name bootstrap
#
# RUN lb build --verbose
#
# RUN mv bootstrap-amd64.hybrid.iso /workdir/output/liveUSB.iso
#
ENTRYPOINT ["bash", "./entrypoint.sh"]


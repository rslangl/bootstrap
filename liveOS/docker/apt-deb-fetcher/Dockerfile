FROM debian:bookworm-20250610

RUN  echo "deb http://deb.debian.org/debian stable main" > /etc/apt/sources.list \
  && apt-get update

RUN apt-get install -y \
    apt-rdepends \
    apt-utils \
    wget \
    gnupg \
    ca-certificates \
    curl

WORKDIR /workdir
COPY packages.txt entrypoint.sh ./

ENTRYPOINT ["bash", "entrypoint.sh"]


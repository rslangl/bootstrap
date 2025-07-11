FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    apt-rdepends \
    apt-utils \
    wget \
    gnupg \
    ca-certificates \
    curl

WORKDIR /workdir
COPY packages.txt fetch-debs.sh ./

ENTRYPOINT ["bash", "entrypoint.sh"]


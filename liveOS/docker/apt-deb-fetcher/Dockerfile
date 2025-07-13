FROM debian:bookworm-20250610

RUN apt-get update && apt-get install -y \
    apt-rdepends \
    apt-utils \
    wget \
    gnupg \
    ca-certificates \
    curl

WORKDIR /workdir
COPY packages.txt entrypoint.sh ./

ENTRYPOINT ["bash", "entrypoint.sh"]


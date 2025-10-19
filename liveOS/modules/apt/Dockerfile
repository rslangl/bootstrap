FROM debian:bookworm-20250610

RUN  echo "deb http://deb.debian.org/debian bookworm main" > /etc/apt/sources.list \
  && apt-get update

RUN apt-get install -y \
    apt-rdepends \
    apt-utils \
    wget \
    gnupg2 \
    ca-certificates \
    curl \
    reprepro \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workdir

COPY packages.txt .
COPY download-deb-packages.sh .
COPY distributions ./config/distributions
COPY entrypoint.sh .

RUN chmod +x download-deb-packages.sh && \
  ./download-deb-packages.sh

ENTRYPOINT ["bash", "./entrypoint.sh"]


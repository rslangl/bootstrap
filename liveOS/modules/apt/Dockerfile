FROM debian:bookworm-20250610 AS deb-fetcher

RUN  echo "deb http://deb.debian.org/debian bookworm main" > /etc/apt/sources.list \
  && apt-get update

RUN apt-get install -y \
    apt-rdepends \
    apt-utils \
    wget \
    gnupg \
    ca-certificates \
    curl

WORKDIR /workdir
COPY packages.txt download-deb-packages.sh ./
RUN download-deb-packages.sh

FROM debian:bookworm-20250610
COPY --from=deb-fetcher deduped.txt

RUN apt-get update && apt-get install -y \
    reprepro gnupg2 curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /

RUN mkdir repo

COPY entrypoint.sh ./

ENTRYPOINT ["bash", "./entrypoint.sh"]


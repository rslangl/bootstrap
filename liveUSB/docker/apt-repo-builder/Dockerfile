FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    reprepro gnupg2 curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /repo

ENTRYPOINT ["reprepro"]


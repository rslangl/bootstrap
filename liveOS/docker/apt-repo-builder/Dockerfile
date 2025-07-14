FROM debian:bookworm-20250610

RUN apt-get update && apt-get install -y \
    reprepro gnupg2 curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /

RUN mkdir repo

COPY entrypoint.sh ./

ENTRYPOINT ["bash", "./entrypoint.sh"]


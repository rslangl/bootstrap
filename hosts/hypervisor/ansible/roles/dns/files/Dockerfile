# NOTE: this dockerfile was initially built to 
# enable centralized builds, with specific configs
FROM gcc:14.2.0

RUN apt update && apt install -y \
  pkg-config \
  autoconf \
  automake \
  libtool \
  bison \
  flex \
  libssl-dev \
  libexpat1-dev \
  libmnl-dev \
  # NOTE: for static linking of gethostbyname
  # when configuring with --enable-fully-static
  #libpcap-dev \
  #libc6-dev \
  #libresolv-dev \
  libprotobuf-dev \
  libprotobuf-c-dev \
  libprotobuf-c1 \
  protobuf-compiler \
  protobuf-c-compiler


VOLUME ["/src", "/output"]

CMD ["./configure --enable-systemd --enable-fully-static --enable-dnstap --enable-ipset --enable-ipsecmod", "make"]


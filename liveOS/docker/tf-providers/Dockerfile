FROM hashicorp/terraform:1.13.0

WORKDIR /terraform

COPY main.tf .

VOLUME ["/mirror"]

CMD ["providers", "mirror", "/mirror"]


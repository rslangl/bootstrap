FROM hashicorp/terraform:1.12.2

WORKDIR /terraform

COPY main.tf .

VOLUME ["/mirror"]

CMD ["providers", "mirror", "/mirror"]


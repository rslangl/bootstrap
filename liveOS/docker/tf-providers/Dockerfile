FROM hashicorp/terraform:1.8.5

WORKDIR /terraform

COPY main.tf .

VOLUME ["/mirror"]

CMD ["providers", "mirror", "/mirror"]


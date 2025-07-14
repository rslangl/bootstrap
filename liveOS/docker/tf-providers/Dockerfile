FROM hashicorp/terraform:1.8.5

WORKDIR /terraform

COPY main.tf .

VOLUME ["/mirror"]

CMD terraform providers mirror /mirror


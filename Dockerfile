FROM openapitools/openapi-generator:cli-latest-release

RUN apt-get update -y &&\
  apt-get install -yy wget

RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
  chmod +x /usr/bin/yq

RUN useradd -ms /bin/bash user
RUN mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/openapi-generator

COPY ./generate.sh /generate.sh
COPY ./api.yaml /api.yaml
COPY ./templates /templates

USER user

ENTRYPOINT ["/generate.sh"]

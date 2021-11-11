FROM openapitools/openapi-generator:cli-latest-release

RUN useradd -ms /bin/bash user
RUN mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/openapi-generator

COPY ./generate.sh /generate.sh
COPY ./templates /templates

USER user

ENTRYPOINT ["/generate.sh"]

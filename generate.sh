#! /bin/bash

set -Ee

function exit {
  echo "Exiting"
}

trap exit EXIT

INPUT_FOLDER=$1
OUTPUT_FOLDER=$2
API_INFO=$3

mkdir /tmp/data

find ${INPUT_FOLDER} -type f \( -name '*.yaml' -o -name '*.yml' -o -name '*.json' \) -print0 | xargs -0 -i -n1 cat {} >> /tmp/data/input.yaml;echo "---" >> /tmp/data/input.yaml

proccesor=$(\
(cat <<EOF
  select(.kind == "CustomResourceDefinition" and .apiVersion == "apiextensions.k8s.io/v1") |
  . as \$i ireduce({}; . * {
    \$i.spec.names.kind:(
    {
      "xml":{
        "name":\$i.spec.group,
        "namespace":(\$i.spec.versions[] | select(.served==true) | .name)
      },
      "title":\$i.spec.names.kind
    } *
    (\$i.spec.versions[] | select(.served==true) | .schema.openAPIV3Schema))
  })
EOF
) | tr -d '\n')
yq ea -P "${proccesor}" /tmp/data/input.yaml > /tmp/data/schemas.yaml

proccesor=$(\
(cat <<EOF
  select(.kind == "CustomResourceDefinition" and .apiVersion == "apiextensions.k8s.io/v1") |
  . as \$i ireduce({}; . * {
    ("/"+\$i.spec.names.kind):{
      "post": {
        "responses": {
          "default": {
            "description": \$i.spec.names.kind
          }
        }
      }
    }
  })
EOF
) | tr -d '\n')
yq ea -P "${proccesor}" /tmp/data/input.yaml > /tmp/data/paths.yaml

cp /api.yaml /tmp/data/api.yaml
if [ -f "${API_INFO}" ]; then
  yq e -I0 -o=json '.api-info' "${API_INFO}" | xargs -0 -I{} yq e -P -i '.info={"title":"CRD Documentation","version":"0.0.0","description":"Generated by [crd-api-doc-gen](https://github.com/srfrnk/crd-api-doc-gen)"} * ({}//{ })' /tmp/data/api.yaml
else
  yq e -P -i '.info={"title":"CRD Documentation","version":"0.0.0","description":"Generated by [crd-api-doc-gen](https://github.com/srfrnk/crd-api-doc-gen)"}' /tmp/data/api.yaml
fi
yq e -I0 -o=json "." /tmp/data/schemas.yaml | xargs -0 -I{} yq ea -P -i ".components.schemas={}" /tmp/data/api.yaml
yq e -I0 -o=json "." /tmp/data/paths.yaml | xargs -0 -I{} yq ea -P -i ".paths={}" /tmp/data/api.yaml

openapi-generator generate -g html2 -t /templates -o ${OUTPUT_FOLDER} -i /tmp/data/api.yaml

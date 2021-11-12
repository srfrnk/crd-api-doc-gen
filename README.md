# crd-api-doc-gen

Kubernetes CRD API Generator

## Basic Usage

To generate an `HTML` API documentation page:

1. Obtain some `json` or `yaml` manifest files that contain one or more `CustomResourceDefinition` objects
1. **Optionally** obtain a file with some api info.
1. Run: `docker run --rm -v $PWD/<PATH_TO_YOUR_FILES>:/<ANY_PATH> ghcr.io/srfrnk/crd-api-doc-gen:<VERSION_TAG> <INPUT_FOLDER_PATH> <OUTPUT_FOLDER_PATH> [<API_INFO_PATH>]`
1. **Note** that these paths are internal to the container. E.g. `docker run --rm -v /mybox/myfiles:/internal ghcr.io/srfrnk/crd-api-doc-gen:latest /internal/some/path /internal/another/path`
1. `<INPUT_FOLDER_PATH>` needs to contain any `yaml` or `json` K8s manifest files with CRD definitions.
1. Find generated HTML page `index.html` inside the specified output folder.

### API Info file

To customize api info you can specify an api-info file.
This file must be in `yaml`/`json` format at have the following structure:

```yaml
api-info:
  version: <ANY STRING>
  title: <ANY STRING>
  description: <ANY MARKDOWN TEXT>
```

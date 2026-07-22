# EDI-ETL Ray image

This image bakes the locked Python dependencies that EDI-ETL otherwise installs
on KubeRay workers through `runtime_env["uv"]`. EDI-ETL and its actively
developed first-party packages continue to ship through Ray `py_modules`.

The requirements export currently includes the private transitive `engmfs` and
`gaze-analysis` repositories. Supply a GitHub token with read access as a
BuildKit secret; never pass it as a build argument.

## Refresh the lock export

With sibling `edi-etl` and `base-images` checkouts:

```bash
cd ../edi-etl
uv export \
  --frozen \
  --no-dev \
  --no-hashes \
  --no-annotate \
  --no-emit-project \
  --no-emit-package common-clock \
  --no-emit-package data-entities \
  --no-emit-package raw-data-readers \
  --no-emit-package spikeglx-sync \
  --no-emit-package enigma-console-db-orm \
  --no-emit-package orcapod \
  --no-emit-package pygraphviz \
  -o ../base-images/images/python/edi-etl/requirements-edi-etl.txt
```

Review changed Git requirements before building. Every private repository must
be readable by the token used for the build.

## Build and test locally

From the `base-images` repository root:

```bash
export GITHUB_TOKEN="<token-with-private-repo-read-access>"
export EDI_ETL_IMAGE="registry.atlab.stanford.edu/edi-etl:plt-1993-$(git rev-parse --short HEAD)"

docker buildx build \
  --platform linux/amd64 \
  --secret id=github_token,env=GITHUB_TOKEN \
  --build-arg GIT_SHA="$(git rev-parse HEAD)" \
  --tag "$EDI_ETL_IMAGE" \
  --file images/python/edi-etl/Dockerfile \
  --load \
  .

docker run --rm --platform linux/amd64 "$EDI_ETL_IMAGE" \
  python -c "import engmfs, gaze_analysis, ray, spiral, torch; print(ray.__version__)"
```

The expected Ray version is `2.53.0`. On Apple Silicon, emulated AMD64 imports
can be slow; the target architecture is nevertheless required by the cluster.

## Push

After authenticating to the in-cluster registry:

```bash
docker login registry.atlab.stanford.edu
docker push "$EDI_ETL_IMAGE"
```

Use the immutable tag in the KubeRay head and worker-group pod templates. Do not
reuse or deploy `latest`.

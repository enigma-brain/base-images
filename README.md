# base-images
A collection of Docker base images for use across Enigma projects

For example, to build the scientific-gpu image, execute the following command from this directory:
`docker build --no-cache -t <insert_image_name> -f ./images/python/scientific-gpu/Dockerfile .`

# instructions for development

To test out updates to these images
1. make a personal fork of this repository
2. add changes and build a new image
3. push to registry.atlab.stanford.edu
4. if changes work, make a PR targeting this repo

### Example: build `op-spikesort-sync` locally

This image builds `FROM ghcr.io/enigma-brain/python-scientific-gpu` (a **private**
package) and installs private enigma-brain repos, so a local build needs a token
with **`read:packages`** (to pull the base) and **`repo` read** (for the git
dependencies). A single classic PAT with `repo` + `read:packages` covers both.

On my local machine (a Mac, hence the `linux/amd64` default below) I do:

```
export GITHUB_TOKEN="ghp_your_token_here"

# 1. Log in to ghcr.io so Docker can pull the private base image
echo "$GITHUB_TOKEN" | docker login ghcr.io -u <your-github-username> --password-stdin

# 2. Build. GIT_SHA defaults to "latest", so the base is pulled as
#    python-scientific-gpu:latest. The token is passed as a BuildKit secret
#    (never baked into a layer) to install the private git dependencies.
DOCKER_BUILDKIT=1 docker build --no-cache \
  --secret id=github_token,env=GITHUB_TOKEN \
  -t registry.atlab.stanford.edu/op-spikesort-sync:$(date +%m-%d-%Y) \
  -f ./images/python/op-spikesort-sync/Dockerfile .
```

and then push to the registry your Ray cluster pulls from:

```
docker push registry.atlab.stanford.edu/op-spikesort-sync:$(date +%m-%d-%Y)
```

> **Note:** On merge to `main`, CI builds and pushes `op-spikesort-sync` to
> `ghcr.io/enigma-brain/op-spikesort-sync` automatically (see
> `.github/workflows/docker-build.yml`). The manual build above is for testing
> changes from a personal fork before opening a PR. In CI, the private-repo
> dependencies are read via a short-lived token minted from the enigma-brain
> GitHub App (`GH_APP_ID` / `GH_APP_PRIVATE_KEY`), which must be installed on
> those dependency repos.

Since I am doing this on my Mac, I have the following in my `~/.zshrc` file:

```
export DOCKER_DEFAULT_PLATFORM=linux/amd64
```

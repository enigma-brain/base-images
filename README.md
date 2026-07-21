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

### Example

Say I made changes to the scientific-gpu image to have it use python 3.12 instead. 

After I make these changes, on my local computer I do:


```
export GITHUB_TOKEN="ghp_your_token_here"
DOCKER_BUILDKIT=1 docker build --no-cache \
  --secret id=github_token,env=GITHUB_TOKEN \
  -t registry.atlab.stanford.edu/op-spikesort-sync:$(date +%m-%d-%Y) \
  -f ./images/python/op-spikesort-sync/Dockerfile .
```

and then

```
docker push registry.atlab.stanford.edu/op-spikesort-sync:$(date +%m-%d-%Y)
```

> **Note:** On merge to `main`, CI builds and pushes `op-spikesort-sync` to
> `ghcr.io/enigma-brain/op-spikesort-sync` automatically (see
> `.github/workflows/docker-build.yml`). The manual build above is only needed
> for testing changes from a personal fork before opening a PR. The CI build
> reads private-repo dependencies with a short-lived token minted from the
> enigma-brain GitHub App (`GH_APP_ID` / `GH_APP_PRIVATE_KEY`); the App must be
> installed on those dependency repos.

Since I am doing this on my Mac, I have the following in my `~/.zshrc` file:

```
export DOCKER_DEFAULT_PLATFORM=linux/amd64
```

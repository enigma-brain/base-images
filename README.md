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

### Example: build `op-spikesort-sync` and push to registry.atlab

The build installs private enigma-brain repos, so export a GitHub token with
`repo` read access; it is passed as a BuildKit secret and never baked into a
layer. Then build and push to `registry.atlab.stanford.edu` (the registry the
Ray cluster currently pulls from):

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

Since I am doing this on my Mac, I have the following in my `~/.zshrc` file:

```
export DOCKER_DEFAULT_PLATFORM=linux/amd64
```

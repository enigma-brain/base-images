# Spike-sorting + sync pipeline image (op-spikesort-sync)
#
# Builds on the GPU scientific base and layers in the pipeline's Python
# dependencies, including private enigma-brain repos. Those are installed with a
# build-time GitHub token passed via a BuildKit secret (never baked into a
# layer); see the README for the build command.
ARG OWNER=enigma-brain
ARG GIT_SHA=latest
FROM ghcr.io/${OWNER}/python-scientific-gpu:${GIT_SHA}

ARG GIT_SHA
LABEL org.opencontainers.image.revision=${GIT_SHA}

# USER_NAME is set up by the base image; redeclare so it resolves in this stage.
ARG USER_NAME=user

# Install the pipeline dependencies (PyPI + private GitHub repos).
# Switch to root to read the build secret. The requirements file re-pins a few
# GPU packages above what the scientific-gpu base ships (ray==2.54.0 vs 2.48.0,
# torchcodec 0.2.x vs 0.1.1) — the pipeline versions must match the Ray cluster,
# so the file stays the authoritative spec and pip upgrades them here.
USER root
COPY ./images/python/op-spikesort-sync/requirements-op-spikesort-sync.txt .
RUN --mount=type=secret,id=github_token \
    export GH_TOKEN=$(cat /run/secrets/github_token) && \
    git config --global credential.helper "!f() { echo username=x-access-token; echo password=$GH_TOKEN; }; f" && \
    pip install --no-cache-dir -r requirements-op-spikesort-sync.txt && \
    git config --global --unset credential.helper
USER ${USER_NAME}

# Default command
CMD ["python", "-c", "import torch; print(f'GPU available: {torch.cuda.is_available()}')"]

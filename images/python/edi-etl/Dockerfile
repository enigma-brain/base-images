# syntax=docker/dockerfile:1.7

ARG PLATFORM=linux/amd64
FROM --platform=${PLATFORM} ubuntu:24.04

ARG GIT_SHA=unknown
ARG PYTHON_VERSION=3.12
ARG USER_GID=10000
ARG USER_NAME=user
ARG USER_UID=10000

LABEL org.opencontainers.image.revision=${GIT_SHA}

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/opt/venv/bin:$PATH \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# wget is required by KubeRay worker init containers. The remaining libraries
# cover EDI-ETL's scientific, video, Graphviz, OpenCV, and Spark dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    default-jre-headless \
    ffmpeg \
    git \
    gfortran \
    graphviz \
    libatlas-base-dev \
    libgl1 \
    libglib2.0-0 \
    libgraphviz-dev \
    libhdf5-dev \
    liblapack-dev \
    libopenblas-dev \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN python${PYTHON_VERSION} -m venv /opt/venv \
    && python -m pip install --upgrade pip setuptools wheel \
    && groupadd --gid ${USER_GID} ${USER_NAME} \
    && useradd --create-home --gid ${USER_GID} --uid ${USER_UID} ${USER_NAME}

COPY images/python/edi-etl/requirements-edi-etl.txt /tmp/requirements-edi-etl.txt

# engmfs and gaze-analysis are private transitive dependencies. BuildKit mounts
# the token for this instruction only; the credential helper is removed before
# the layer is committed, so no credential is retained in the image.
RUN --mount=type=secret,id=github_token,required=true \
    export GH_TOKEN="$(cat /run/secrets/github_token)" \
    && git config --global credential.helper \
        "!f() { echo username=x-access-token; echo password=$GH_TOKEN; }; f" \
    && python -m pip install --no-cache-dir -r /tmp/requirements-edi-etl.txt \
    && git config --global --unset credential.helper \
    && python -c "import engmfs, gaze_analysis, ray, spiral, torch; assert ray.__version__ == '2.53.0'"

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

CMD ["python", "-c", "import ray; print(f'EDI-ETL Ray {ray.__version__}')"]

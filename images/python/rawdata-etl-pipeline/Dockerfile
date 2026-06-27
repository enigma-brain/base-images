# GPU-enabled scientific Python image
ARG OWNER=enigma-brain
ARG PYTHON_VERSION=3.12
# the following may have been commented out because our GPU nodes on k8s use CUDA 12.2, later versions not compatible?
#FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04
FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive

# Define build arguments
ARG USER_UID=10000
ARG USER_GID=10000
ARG USER_NAME=user

# redefine the ARGs
ARG PYTHON_VERSION

# Add deadsnakes PPA for Python 3.12
# Ubuntu 22.04 only includes Python 3.10 in its default repositories.
# The deadsnakes PPA is a community-maintained repository that provides
# newer Python versions (including 3.12) compiled for older Ubuntu releases.
# We could use a newer Ubuntu, but 22.04 seemed to be the latest with the contraint of CUDA 12.2 support.
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && rm -rf /var/lib/apt/lists/*

# Install Python and system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv \
    python3-pip \
    build-essential \
    libopenblas-dev \
    liblapack-dev \
    libhdf5-dev \
    libatlas-base-dev \
    gfortran \
    wget \
    git \
    curl \
    graphviz \
    libgraphviz-dev \
    ffmpeg \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Create and activate virtual environment
# This avoids the externally-managed-environment error
RUN python${PYTHON_VERSION} -m venv --system-site-packages /opt/venv && \
    . /opt/venv/bin/activate && \
    python -m pip install --upgrade pip setuptools wheel && \
    mkdir -p /etc/pip && \ 
    # Disable falling back to user-site
    echo "[global]\nuser = false\n" > /etc/pip.conf
# Defaults to using the venv
ENV PATH="/opt/venv/bin:$PATH"


# Setup user and group with given UID and GID as well as given name
# If it already exists, change the group name or user name to the given name
RUN if ! getent group ${USER_GID} > /dev/null; then \
    groupadd -g ${USER_GID} ${USER_NAME}; \
    else \
    CURRENT_GROUP=$(getent group ${USER_GID} | cut -d: -f1) && \
    groupmod -n ${USER_NAME} ${CURRENT_GROUP}; \
    fi && \
    if ! getent passwd ${USER_UID} > /dev/null; then \
    useradd -m -u ${USER_UID} -g ${USER_GID} ${USER_NAME}; \
    else \
    CURRENT_USER=$(getent passwd ${USER_UID} | cut -d: -f1) && \
    usermod -l ${USER_NAME} ${CURRENT_USER}; \
    fi && \
    chown -R ${USER_NAME}:${USER_GID} /opt/venv
# Switch to the new user
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# Upgrade pip and setuptools - necessary to avoid some erros in package installations
RUN pip install --no-user --no-cache-dir --upgrade pip setuptools wheel

# Install common scientific packages
COPY ./images/python/scientific/requirements-common.txt .
RUN pip install --no-user --no-cache-dir -r requirements-common.txt

# Install all packages (PyPI + GitHub) with git credentials
# change to root user to use secrets
USER root
COPY ./images/python/rawdata-etl-pipeline/requirements-rawdata-etl.txt .
RUN --mount=type=secret,id=github_token \
    export GH_TOKEN=$(cat /run/secrets/github_token) && \
    git config --global credential.helper "!f() { echo username=x-access-token; echo password=$GH_TOKEN; }; f" && \
    pip install --no-cache-dir -r requirements-rawdata-etl.txt && \
    git config --global --unset credential.helper
USER ${USER_NAME}

# Default command
CMD ["python", "-c", "import torch; print(f'GPU available: {torch.cuda.is_available()}')"]

# Default from amd64
ARG TARGETARCH=amd64
FROM --platform=linux/amd64 ubuntu:22.04 AS base-amd64
FROM --platform=linux/arm64 nvcr.io/nvidia/l4t-ml:r36.2.0-py3 AS base-arm64
FROM base-${TARGETARCH} AS final

# Default versions of tools
ARG SERVER_HOST="localhost"
ARG NVM_VERSION=0.40.4
ARG NODE_VERSION=24.14.0

ENV SERVER_HOST="localhost"
ENV NVM_VERSION=0.40.4
ENV NODE_VERSION=24.14.0

# Set BASH_ENV
ENV BASH_ENV "/etc/profile"

ARG USER=milimo
ARG GROUP=milimo
ARG USER_UID=2000
ARG USER_GID=2000
ARG USER_HOME=/home/${USER}

# Add user and group for devops user
RUN groupadd -g "${USER_GID}" "${GROUP}" \
  && useradd -d "${USER_HOME}" -u "${USER_UID}" -g "${USER_GID}" -m -s /bin/bash "${USER}" \
  && mkdir -p ${USER_HOME}/.ansible/tmp \
  && chown -R "${USER_UID}":"${USER_GID}" ${USER_HOME}/.ansible 

# Update, Upgrade and install prerequisites
RUN  apt-get -y update \
  && apt-get -y install git wget curl python3 python3-pip python3-venv python3-setuptools supervisor

# Download and install nvm:
RUN mkdir -p /usr/local/nvm \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | NVM_DIR=/usr/local/nvm bash \
  && \. "/usr/local/nvm/nvm.sh" \
  && nvm install 24.14.0 \
  && ln -s /usr/local/nvm/versions/node/v24.14.0/bin/* /usr/bin/

# Installation and backend setup
RUN cd /usr/share \
  && git clone https://github.com/mainza-ai/milimovideo.git \
  && cd milimovideo \
  && python3 -m venv milimov \
  && ./milimov/bin/pip install -e ./LTX-2/packages/ltx-core \
  && ./milimov/bin/pip install -e ./LTX-2/packages/ltx-pipelines \
  && ./milimov/bin/pip install -e ./flux2 \
  && ./milimov/bin/pip install -r backend/requirements.txt \
  && python3 -m venv sam3_env \
  && ./sam3_env/bin/pip install -e sam3 \
  && ./sam3_env/bin/pip install fastapi uvicorn python-multipart psutil pycocotools huggingface_hub \
  && chown -R milimo:milimo -R /usr/share/milimovideo 

# Override configuration to allow access without in localhost
COPY files/vite.config.ts /usr/share/milimovideo/web-app/vite.config.ts
 
# Supervisord related for Services
COPY files/run_sam.sh /usr/share/milimovideo/run_sam.sh
COPY files/run_frontend.sh /usr/share/milimovideo/run_frontend.sh
COPY files/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/log/supervisor \
 && mkdir -p /var/run/supervisor \
 && chown $USER:$GROUP /var/log/supervisor /var/run/supervisor

# Define workdir
WORKDIR /usr/share/milimovideo

# Launch container
USER milimo
CMD ["supervisord", "--configuration=/etc/supervisord.conf"]

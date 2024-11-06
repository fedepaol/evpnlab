FROM kindest/node:v1.29.2

RUN mv /etc/containerd/config.toml /etc/containerd/config.toml.tmp
RUN apt update && apt install -y docker.io
RUN mv /etc/containerd/config.toml.tmp /etc/containerd/config.toml

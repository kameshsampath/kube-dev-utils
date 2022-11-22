FROM alpine

ARG TARGETARCH

ARG HELM_VERSION=3.9.0
ARG KUBECTL_VERSION=1.24.1
ARG KUSTOMIZE_VERSION=v4.5.5
ARG KIND_VERSION=v0.14.0
ARG CRANE_VERSION=latest

# Install helm (latest release)
# ARG BASE_URL="https://storage.googleapis.com/kubernetes-helm"
ARG BASE_URL="https://get.helm.sh"
ARG TAR_FILE="helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz"

RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories

RUN apk add --update --no-cache curl ca-certificates bash bash-completion git docker docker-compose direnv wget net-tools tcpdump iputils nmap arp-scan bind-tools  httpie jq yq gettext go

# add helm
RUN curl -sL ${BASE_URL}/${TAR_FILE} | tar -xvz && \
    mv linux-${TARGETARCH}/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-${TARGETARCH}

# Helm Plugins - helm-diff, helm-unittest
RUN helm plugin install https://github.com/databus23/helm-diff \
  && helm plugin install https://github.com/quintush/helm-unittest \
  && helm plugin install https://github.com/chartmuseum/helm-push \
  && rm -rf /tmp/helm-*

# kubectl
RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# kind
RUN curl -sLO https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-linux-${TARGETARCH} && \
    mv kind-linux-${TARGETARCH} /usr/bin/kind && \
    chmod +x /usr/bin/kind

# Install k3d
RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install ko
RUN apk add ko

# kustomize (latest release)
RUN curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${TARGETARCH}.tar.gz && \
    tar xvzf kustomize_${KUSTOMIZE_VERSION}_linux_${TARGETARCH}.tar.gz && \
    mv kustomize /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize

# Argo CD CLI
RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 \
   && chmod +x /usr/local/bin/argocd

## Crane
RUN go install github.com/google/go-containerregistry/cmd/crane@latest

# kubens
RUN curl -sL -o /usr/local/bin/kubens https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens \
  && chmod +x /usr/local/bin/kubens

# kubectx
RUN curl -sL -o /usr/local/bin/kubectx https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx \
  && chmod +x /usr/local/bin/kubectx

# kubectl aliasses
RUN curl https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases -o /usr/local/.kubectl_aliases

WORKDIR /apps

RUN mkdir -p /apps/.kube \ 
   && echo 'eval "$(direnv hook bash)"'  >> ~/.bashrc \
   && printf "source /usr/share/bash-completion/bash_completion\ncomplete -F __start_kubectl k\nexport do=('--dry-run=client' '-o' 'yaml')\n[ -f /usr/local/.kubectl_aliases ] && source /usr/local/.kubectl_aliases\n" >> ~/.bashrc

ENV PATH="${PATH}:${HOME}/go/bin"
ENV KUBECONFIG=/apps/.kube/config

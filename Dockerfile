#syntax=docker/dockerfile:1.3-labs

FROM alpine
ARG TARGETARCH

# Ignore to update versions here
# docker build --no-cache --build-arg KUBECTL_VERSION=${tag} --build-arg HELM_VERSION=${helm} --build-arg KUSTOMIZE_VERSION=${kustomize_version} -t ${image}:${tag} .
ARG HELM_VERSION=3.9.0
ARG KUBECTL_VERSION=1.24.1
ARG KUSTOMIZE_VERSION=v4.5.5
ARG KIND_VERSION=v0.14.0
ARG KNATIVE_CLIENT_VERSION=v1.6.0
ARG KNATIVE_QUICKSTART_VERSION=v1.5.1

# Install helm (latest release)
# ENV BASE_URL="https://storage.googleapis.com/kubernetes-helm"
ENV BASE_URL="https://get.helm.sh"
ENV TAR_FILE="helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz"
RUN apk add --update --no-cache curl ca-certificates bash git && \
    curl -sL ${BASE_URL}/${TAR_FILE} | tar -xvz && \
    mv linux-${TARGETARCH}/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-${TARGETARCH}

# add helm-diff
RUN helm plugin install https://github.com/databus23/helm-diff && rm -rf /tmp/helm-*

# add helm-unittest
RUN helm plugin install https://github.com/quintush/helm-unittest && rm -rf /tmp/helm-*

# add helm-push
RUN helm plugin install https://github.com/chartmuseum/helm-push && rm -rf /tmp/helm-*

RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

RUN curl -sLO https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-linux-${TARGETARCH} && \
    mv kind-linux-${TARGETARCH} /usr/bin/kind && \
    chmod +x /usr/bin/kind

# Knative
RUN curl -sLO https://github.com/knative/client/releases/download/knative-${KNATIVE_CLIENT_VERSION}/kn-linux-${TARGETARCH} && \
    mv kn-linux-${TARGETARCH} /usr/bin/kn && \
    chmod +x /usr/bin/kn

# Knative quickstart
RUN curl -sLO https://github.com/knative-sandbox/kn-plugin-quickstart/releases/download/knative-${KNATIVE_QUICKSTART_VERSION}/kn-quickstart-linux-${TARGETARCH} && \
    mv kn-quickstart-linux-${TARGETARCH} /usr/bin/kn-quickstart && \
    chmod +x /usr/bin/kn-quickstart

# Install kustomize (latest release)
RUN curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${TARGETARCH}.tar.gz && \
    tar xvzf kustomize_${KUSTOMIZE_VERSION}_linux_${TARGETARCH}.tar.gz && \
    mv kustomize /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize

# Install jq
RUN apk add --update --no-cache jq

# Install yq
RUN apk add --update --no-cache yq

# Install for envsubst
RUN apk add --update --no-cache gettext

# Install yq
RUN apk add --update --no-cache yq

# Install kubens
RUN curl -sL -o /usr/local/bin/kubens https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens \
  && chmod +x /usr/local/bin/kubens

# Install kubectx
RUN curl -sL -o /usr/local/bin/kubectx https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx \
  && chmod +x /usr/local/bin/kubectx

WORKDIR /apps

RUN mkdir -p /apps/.kube

ENV KUBECONFIG=/apps/.kube/config

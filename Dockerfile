FROM alpine

# Ignore to update versions here
# docker build --no-cache --build-arg KUBECTL_VERSION=${tag} --build-arg HELM_VERSION=${helm} --build-arg KUSTOMIZE_VERSION=${kustomize_version} -t ${image}:${tag} .
ARG HELM_VERSION=3.9.0
ARG KUBECTL_VERSION=1.24.1
ARG KUSTOMIZE_VERSION=v4.5.5

# Install helm (latest release)
# ENV BASE_URL="https://storage.googleapis.com/kubernetes-helm"
ENV BASE_URL="https://get.helm.sh"
ENV TAR_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"
RUN apk add --update --no-cache curl ca-certificates bash git && \
    curl -sL ${BASE_URL}/${TAR_FILE} | tar -xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64

# add helm-diff
RUN helm plugin install https://github.com/databus23/helm-diff && rm -rf /tmp/helm-*

# add helm-unittest
RUN helm plugin install https://github.com/quintush/helm-unittest && rm -rf /tmp/helm-*

# add helm-push
RUN helm plugin install https://github.com/chartmuseum/helm-push && rm -rf /tmp/helm-*

# Install kubectl (same version of aws esk)
RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# Install kustomize (latest release)
RUN curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    tar xvzf kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
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

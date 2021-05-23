FROM alpine

ENV NEXUS_URL="http://localhost:8081"

ARG KUBECTL_VERSION=1.20.1

RUN apk update \
    && apk upgrade \
	&& apk add --no-cache curl

RUN  curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

RUN mkdir -p /deployments

WORKDIR /deployments

COPY etc/* /deployments/

CMD ["/deployments/config.sh"]
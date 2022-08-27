# Kube Dev Utils

My collection of reusable manifests and tools image that helps in application development and deployment with Kubernetes.

## Kube Dev Tools

The kube dev tools image is available at `kameshsampath/kube-dev-tools`.

The tools image has following tools,

- Helm
- Kubectl
- Kustomize
- Kind
- Knative Client
- Knative Quickstart
- Argo CD CLI
- Kubens
- Kubectx
- K3d
- direnv
- envsubst
- docker cli
- docker-compose
- httpie
- jq
- yq

### Build Args

- HELM_VERSION: `3.9.0`
- KUBECTL_VERSION: `1.24.1`
- KUSTOMIZE_VERSION: `v4.5.5`
- KIND_VERSION: `v0.14.0`
- KNATIVE_CLIENT_VERSION: `v1.6.0`
- KNATIVE_QUICKSTART_VERSION: `v1.5.1`

### Environment Variables

- KUBECONFIG: `/apps/.kube/config`

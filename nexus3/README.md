# Install Sonatype Nexus3 Repository OSS

## Manual

```shell
kubectl create ns nexus3
kubectl config set-context --current --namespace=nexus3
kubectl apply --namespace nexus3 -f manual/
```

## Using Helm

```
helm repo add sonatype https://sonatype.github.io/helm3-charts/
helm repo update
helm install \
  -f helm/values.yaml 
  nexus3 sonatype/nexus-repository-manager
```

### Debug 

```
helm install \
  -f helm/values.yaml \
  --debug \
  --dry-run \
  nexus3 sonatype/nexus-repository-manager
```

## Check nexus.properties 

```
kubectl exec -n nexus3 -it (kubectl get pods -n nexus3 -lapp.kubernetes.io/name=nexus-repository-manager | awk 'NR==2{print $1}') -- cat /nexus-data/etc/nexus.properties
```
# Install Sonatype Nexus3 Repository OSS

## Manual

```shell
kubectl apply -k .
```

## Check nexus.properties

```shell
kubectl exec -n nexus3 -it (kubectl get pods -n nexus3 -lapp.kubernetes.io/name=nexu3| awk 'NR==2{print $1}') -c nexus-config -- cat /nexus-data/etc/nexus.properties
```

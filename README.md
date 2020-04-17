# Minimal private-only EKS cluster

## Sources
- https://github.com/aws/containers-roadmap/issues/298#issuecomment-584403418

## Key components

- VPC endpoint for s3 for Docker images of base EKS components
- VPC endpoints for ECR for Docker images of base EKS components
- VPC endpoint for EC2
- VPC with `enableDnsHostnames` and `enableDnsSupport` enabled

## Process

1. setup remote backend for terraform
2. `terraform plan`
3. `terraform apply`
4. extend!

## Result

```
NAME                                           STATUS   ROLES    AGE     VERSION
ip-10-20-1-122.eu-central-1.compute.internal   Ready    <none>   2m50s   v1.15.10-eks-bac369
```

```
kubectl get pods --all-namespaces
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-k7znj             1/1     Running   0          2m43s
kube-system   coredns-5b6dbb4b59-nqqqv   1/1     Running   0          6m29s
kube-system   coredns-5b6dbb4b59-wkcf9   1/1     Running   0          6m29s
kube-system   kube-proxy-mz4ff           1/1     Running   0          2m43s
```

It basically means that Kubernetes nodes were able to pull all the assets
from VPC endpoins. Noice!

## IAM roles for K8S workload

If you need IAM roles for Kubernetes workload, use IAM roles for Kubernetes Service Accounts.
That's the best and most secure way how to handle this. See more in our blog post:
https://blog.pipetail.io/posts/2020-04-13-more-eks-tips/

## Need any help?

[contact@pipetail.io](mailto:contact@pipetail.io), [@MstrsObserver](https://twitter.com/MstrsObserver)
or [@MarekBartik](https://twitter.com/MarekBartik). Simple.

## License

MIT



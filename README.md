# Minimal private-only EKS cluster

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

## IAM roles for K8S workload

If you need IAM roles for Kubernetes workload, use IAM roles for Kubernetes Service Accounts.
That's the best and most secure way how to handle this. See more in our blog post:
https://blog.pipetail.io/posts/2020-04-13-more-eks-tips/



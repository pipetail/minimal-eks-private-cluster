provider "aws" {
  region                  = var.region
  skip_metadata_api_check = true
}

provider "kubernetes" {
  host             = aws_eks_cluster.main.endpoint
  token            = data.aws_eks_cluster_auth.eks_main.token
  load_config_file = false
  insecure         = true
}
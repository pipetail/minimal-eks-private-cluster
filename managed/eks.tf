resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_master.arn

  vpc_config {

    subnet_ids = [
      aws_subnet.private_0.id,
      aws_subnet.private_1.id,
      aws_subnet.private_2.id,
    ]

    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs = [
      "0.0.0.0/0"
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_master_default_cluster,
    aws_iam_role_policy_attachment.eks_master_default_service,
    aws_cloudwatch_log_group.eks,
  ]

  version = var.kubernetes_version
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "default"
  node_role_arn   = aws_iam_role.eks_worker.arn

  instance_types = [
    var.instance_type,
  ]

  subnet_ids = [
    aws_subnet.private_0.id,
    aws_subnet.private_1.id,
    aws_subnet.private_2.id,
  ]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_worker_cni,
    aws_iam_role_policy_attachment.eks_worker_ecr,
  ]

}


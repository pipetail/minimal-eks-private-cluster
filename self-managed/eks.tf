data "aws_ami" "eks" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.main.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"]
}

resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_master.arn

  vpc_config {

    subnet_ids = [
      aws_subnet.private_0.id,
      aws_subnet.private_1.id,
      aws_subnet.private_2.id,
    ]

    security_group_ids = [
      aws_security_group.eks.id,
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

resource "aws_placement_group" "eks_worker_default" {
  name     = "eks_worker_default"
  strategy = "spread"
}

resource "aws_iam_instance_profile" "eks_worker_default" {
  name = "eks_worker"
  role = aws_iam_role.eks_worker.name
}

resource "aws_launch_configuration" "eks_worker_default" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.eks_worker_default.name
  image_id                    = data.aws_ami.eks.id
  instance_type               = var.instance_type
  name_prefix                 = "eks"
  security_groups = [
    aws_security_group.eks.id,
  ]

  user_data_base64 = base64encode(local.eks_worker_default_userdata)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks_worker_default" {
  placement_group      = aws_placement_group.eks_worker_default.id
  desired_capacity     = 3
  launch_configuration = aws_launch_configuration.eks_worker_default.id
  max_size             = 6
  min_size             = 3
  name                 = "eks_default"
  vpc_zone_identifier = [
    aws_subnet.private_0.id,
    aws_subnet.private_1.id,
    aws_subnet.private_2.id,
  ]

  tag {
    key                 = "kubernetes.io/cluster/${var.eks_cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  // set you CA accordingly e.g.
  // --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = false
  }

  # here specify your node labels for cluster autoscaler
  # https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-can-i-scale-a-node-group-to-0
  # tag {
  #   key = "k8s.io/cluster-autoscaler/node-template/label/nodetype"
  #   value = "spot"
  #   propagate_at_launch = true
  # }

  lifecycle {
    ignore_changes = [
      desired_capacity,
    ]
  }
}

// with this setup we don't need AWS CLI (v2) nor AWS IAM authenticator
data "aws_eks_cluster_auth" "eks_main" {
  name = aws_eks_cluster.main.name
}

resource "kubernetes_config_map" "eks_main" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = templatefile(
      "${path.module}/assets/templates/aws-auth.yaml",
      {
        node_role_arn = aws_iam_role.eks_worker.arn
      }
    )
  }

  depends_on = [
    null_resource.wait_for_eks,
  ]
}

// Sometimes it takes some time till EKS is up
resource "null_resource" "wait_for_eks" {

  provisioner "local-exec" {
    command = "until wget --no-check-certificate -O - -q $ENDPOINT/healthz >/dev/null; do sleep 4; done"
    environment = {
      ENDPOINT = aws_eks_cluster.main.endpoint
    }
  }

  depends_on = [
    aws_eks_cluster.main,
  ]
}


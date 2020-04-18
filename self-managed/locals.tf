locals {
  eks_worker_default_userdata = templatefile(
    "${path.module}/assets/templates/userdata_eks_default.sh",
    {
      endpoint           = aws_eks_cluster.main.endpoint,
      authority_data     = aws_eks_cluster.main.certificate_authority.0.data,
      cluster_name       = aws_eks_cluster.main.name
      kubelet_extra_args = "" // labels, taints, whatever
    }
  )
}
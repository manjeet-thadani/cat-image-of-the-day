module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "15.0.0"

  cluster_name    = "${var.cluster_name}"
  cluster_version = var.master_version_prefix
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  node_groups = var.cluster_node_groups

  depends_on = [module.vpc]
}

resource "vault_generic_secret" "management-config" {
  path = "${var.environment}/k8s/${var.cluster_name}"

  data_json = jsonencode({
    cluster                = var.cluster_name
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    endpoint               = module.eks.cluster_endpoint
  })
}

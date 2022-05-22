# Frontend Bucket + Cloudfront configurations
website_bucket_name = "demo--website"
assets_bucket_name = "demo--assets"

# Redis configurations
redis_name_prefix = "demo-redis"
redis_node_type = "cache.t3.small"
redis_engine_version = "6.x"
redis_family = "redis6.x"

# EKS cluster configurations
cluster_name = "demo-cluster"
environment = "demo-cluster"

region = "us-west-2"

vpc_cidr = "10.97.240.0/20"
vpc_private_subnets =  ["10.97.240.0/22", "10.97.244.0/22"]
vpc_public_subnets = ["10.97.248.0/22", "10.97.252.0/22"]

master_version_prefix = "1.21"

cluster_node_groups = {
  node_pool_a = {
    desired_capacity = 5
    max_capacity     = 10
    min_capacity     = 5

    instance_type = "t3.xlarge"
  }
}

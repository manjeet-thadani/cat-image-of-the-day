# Frontend Bucket + Cloudfront configurations
variable "website_bucket_name" {  
  type        = string  
  description = "Name of the s3 bucket to host website code."
}

variable "assets_bucket_name" {  
  type        = string  
  description = "Name of the s3 bucket to host assets."
} 

# Redis configurations
variable "redis_name_prefix" {  
  type        = string  
  description = "Name prefix for redis nodes."
}

variable "redis_node_type" {  
  type        = string  
  description = "Redis machine type."
}

variable "redis_engine_version" {  
  type        = string  
  description = "Redis engine version."
}

variable "redis_family" {  
  type        = string  
  description = "Redis Family."
}

# EKS cluster configurations
variable "cluster_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_private_subnets" {
  type    = list(string)
}

variable "vpc_public_subnets" {
  type    = list(string)
}


variable "master_version_prefix" {
  type = string
}

variable "cluster_node_groups" { 
  default = {
    node_pool_a = {
      desired_capacity = 1
      max_capacity     = 5
      min_capacity     = 1

      instance_type = "t2.small"
    }
  }
}

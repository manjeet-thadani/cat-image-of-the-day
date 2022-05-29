# Image of the Hour - Cat Version

## Introduction
This repository contains a website that shows an image of the cat of the hour.
1. Web application based on Angular. It should show a cat of the hour by calling an API
2. A simple Node.js application that serves the image of the day.
3. Write a simple Node.js API that sends the image of the hour. It should be read from a MongoDB database and cached in a Redis cache for 1hour.

## Running Demo
- `Frontend`: http://duvqje3e0hmt0.cloudfront.net/
- `Backend`: http://a2e8d5688a0594658bfefb701419163f-239422344.us-west-2.elb.amazonaws.com/api/v1/hour-image

## Architecture

High Level Architecture Diagram

<p align="center"><img src="https://i.ibb.co/dP98T2q/hld.jpg" width="800"></p>

**NOTE**
- HPA is enabled on Backend Application
- (optional) Multi-region EKS clusters could be used to support wide geographies
 
## Local Setup & Testing

Refer to this [README.md](application/README.md) for details related to the codebase and local setup

## Deployment 

### Prerequisite
- [AWS Account](https://aws.amazon.com/resources/create-account/)
- Access/Secret keys are generated and configured (Ref: [link](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html))
- Required CLI Tools: [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli), [Kubectl](https://kubernetes.io/docs/tasks/tools/), [Helm](https://helm.sh/docs/intro/install/)


### Step 1: Setup S3 bucket to store terraform state

Update `terraform/01-prerequisite/envs/terraform.tfvars` file to add required bucket name and region.

```bash
$ cd terraform/01-prerequisite/

$ source ./envs/source.rc
$ terraform plan
$ terraform apply
```

### Step 2: Setup cloud services

We would setup following cloud services:
- `S3 Buckets`: 2 s3 buckets would be created to host the website and assets (cat images) respectively
- `Cloudfront`: 2 CloudFront distributions would be created to serve content from both S3 buckets
- `VPC`: VPC in which EKS & Redis would be created
- `EKS`: Kubernetes cluster to deploy backend application and other services
- `Redis`: setup AWS ElastiCache for Redis - would be used by the backend application

1. Update bucket name in `terraform/02-project-setup/envs/backend.conf` with the bucket created in `Step 1`
2. Update `terraform/02-project-setup/envs/terraform.tfvars`
NOTE: make sure to provide unused CIDR range for VPC and subnets

```bash
$ cd terraform/02-prerequisite/

$ source ./envs/source.rc
$ terraform plan
$ terraform apply
```

### Step 3: Upload asset images in S3

Upload imaged stored in `application/frontend/assets/` folder to assets S3 bucket. After uploading, the images should be accessible from the cloudfront distribution.

Example: https://d3gpownff003dw.cloudfront.net/06.jpg

### Step 4: Deploy MongoDB and ArgoCD in k8s

#### Deploy MongoDB (optional):

We can deploy HA MongoDB in the k8 cluster or can use MongoDB Atlas to provide MongoDB instances. The following guide assumes that Mongodb would be installed in Kubernetes cluster.

[Refer: Deploy MongoDB in Cluster](https://www.mongodb.com/docs/kubernetes-operator/master/tutorial/deploy-replica-set/)

**NOTE**: Make sure to provide `username`, `password`, and `db_name` while creating MongoDB. This would be used further to connect with database.

#### Deploy ArgoCD

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes. We would be using it to manage CD for Backend deployments.

[Refer: Install ArgoCD](https://argo-cd.readthedocs.io/en/stable/getting_started/)

**NOTE**: The default username of the ArgoCD UI would be `admin` and password can be obtained via below-mentioned command:

```bash
kubectl get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Step 5: Add Assets data in MongoDB

Backend application would connect with MongoDB to get a random image URL i.e. image of the hour. Therefore, before starting our backend application, we need to make sure that the MongoDB collection has the list of all images URLs.

1. Exec into the MongoDB pod

```bash
kubectl exec -it <pod-name> bash
```

2. Connect with MongoDB
```bash
$ mongo admin -u <USERNAME> -p '<PASSWORD>'
``` 

3. Insert assets in the database collection

Replace following:
- `<DATABASE-NAME>` with actual db name 
- `d3gpownff003dw` with your assets cloudfront distribution URL

```bash
use <DATABASE-NAME>
db.createCollection('images');

db.images.insertMany([
    { image: "https://d3gpownff003dw.cloudfront.net/01.jpg" },
    { image: "https://d3gpownff003dw.cloudfront.net/02.jpeg" },
    { image: "https://d3gpownff003dw.cloudfront.net/03.jpg" },
    { image: "https://d3gpownff003dw.cloudfront.net/04.jpg" },
    { image: "https://d3gpownff003dw.cloudfront.net/05.jpg" },
    { image: "https://d3gpownff003dw.cloudfront.net/06.jpg" },
    { image: "https://d3gpownff003dw.cloudfront.net/07.jpg" },
    { image: "https://d3gpownff003dw.cloudfront.net/08.avif" },
]);
```

### Step 6: Deploy Backend

#### (optional) Build and Push docker image to your container repository

```bash
$ cd ./application/backend
$ docker build . -t <YOUR-IMAGE-REPO-NAME>
$ docker push <YOUR-IMAGE-REPO-NAME>
```

**NOTE**: Make sure to authenticate yourself with your remote container repository before pushing docker image. 

#### Deploy Backend
Update `application/backend/k8/values.yaml` 

Deploy Helm chart:
```bash
$ helm install -f values.yaml demo-backend ./application/backend/k8
```

Once deployed, get the External Address of Load balancer service:
```bash
$ kubectl get service demo-backend-lb

NAME              TYPE           CLUSTER-IP     EXTERNAL-IP                                                              PORT(S)        AGE
demo-backend-lb   LoadBalancer   172.20.27.78   a2e8d5688a0594658bfefb701419163f-239422344.us-west-2.elb.amazonaws.com   80:31871/TCP   12h
```

Access the backend server API:

```bash
$ curl http://<EXTERNAL-IP>/api/v1/hour-image

Example:
$ curl http://a2e8d5688a0594658bfefb701419163f-239422344.us-west-2.elb.amazonaws.com/api/v1/hour-image
```

Response should be like: (NOTE: image number could be different)
```bash
{"image":"https://d3gpownff003dw.cloudfront.net/images/04.jpg"}
```

### Step 7: Deploy Frontend

Update `apiURL` in `application/frontend/src/environments/environment.prod.ts` with the API URL obtained from previous step.

Build frontend codebase:
```bash
$ cd application/frontend/
$ npm install -g @angular/cli
$ npm install
$ ng build –prod
```

This should generate build manifest files within `application/frontend/dist` directory. Upload the manifest files (in dist folder) to `website s3 bucket` created in `Step 2`. 

After manifests are uploaded, those should be accessible via the Website Cloudfront distribution (URL can be obtained from Cloudfront service section in AWS).

Try to access the website. Example: http://duvqje3e0hmt0.cloudfront.net/

It should show a random image from list of our assets and it should be cached for next 1 hour. 

### Step 8: CI-CD

#### Backend CI

NOTE: Assuming the docker images would be uploaded to dockerhub

- Add `DOCKER_USER` and `DOCKER_PASSWORD` in GitHub secrets containing username and password for dockerhub
- Update dockerimage name in `.github/workflows/backend.yaml` to correspond to your docker repository

**TODO**: Need to work on auto trigger ArgoCD deployment from GitHub Action

#### Frontend CI

- Create an IAM user with access to website S3 bucket & Cloudfront distribution. Sample Policy:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::<S3-BUCKET-NAME>"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::<S3-BUCKET-NAME>/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudfront:Get*",
                "cloudfront:List*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudfront:*"
            ],
            "Resource": "arn:aws:cloudfront::<AWS-ACCOUNT-ID>:distribution/<DISTRIBUTION-ID>"
        }
    ]
}
``` 

- Generate access key and secret key for this user.

- Add following secrets in Github Secrets:
```
AWS_ACCESS_KEY_ID: Access Key generated for IAM user
AWS_SECRET_ACCESS_KEY: Secret Key generated for IAM user
AWS_DEFAULT_REGION: AWS region
S3_BUCKET_NAME: Website S3 bucket name
CF_ID: Website Cloudfront distribution Id 
```


## TODO / Future Improvements

- Add ELK/EFK Stack for logging and monitoring
- Support for using external secrets manager example: AWS Secret Manager, Hashicorp Vault, etc
- Add CD in Backend Github Action
- Add docker image tagging/versioning in Backend CI
- Setup multiple replicas of Backend application in different nodes/zones for HA
- Add support for mTLS between frontend and backend
- Support for Velero for continuous backups and DR
- Integrate WAF 

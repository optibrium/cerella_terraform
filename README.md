<img
  src="http://optibrium.com/wp-content/uploads/2022/09/AugChem-Portrait-logosm.jpg"
  alt="Augmented Chemistry logo"
  title="Augmented Chemistry logo"
  style="display: inline-block; margin: 0 auto; max-width: 100px">

## Optibrium Cerella Terraform

### Summary

This repository defines the Terraform scripts used to create the infrastructure resources that will host a Cerella evaluation platform.

There are expected to by minor differences in the installation of a full Cerella service.

### Terraform Version

Version `1.1.2` of this repository targets Terraform `0.14.5`

### Pre-requisites

There are two AWS account pre-requisites, an S3 bucket to hold the Terraform backend and a Route53 Domain hosting a valid public FQDN. These must be created in the same account, and must be configurable by the AWS profile used.

These can be created independently with Terraform, or via the Console.

### Architectural overview

An AWS VPC is created in the `EU-WEST-1` region. EKS is currently best supported in this region.

A central EKS cluster is created with an Auto-scaling worker node pool.

An ALB with an ACM wildcard SSL certificate, validated using the pre-created Route53 zone, is used to balance HTTPS ingress into the cluster.

An IAM role granting the worker nodes access to the datasource S3 bucket.

### Usage instructions

Please create a Route53 Hosted Zone and an S3 bucket within the target account. If you already have a DNS domain or subdomain that you would like to use, it is possible to point NS (DNS Nameserver) records at the NS entries enumerated in the Route53 Hosted Zone.

Please copy the copy_me.tf.example file to a new location and substitute the placeholders. If you do not use AWS-Cli configuration profiles, your profile name is `default`, or can be removed entirely. Sadly the EKS-AMI used in the Cerella module is scoped to `EU-WEST-1`, it is advised not to change this yourself, but we can supply alternative AMI-IDs if you require hosting in different regions.

Please create the resources with Terraform, and return the output to Optibrium Support.

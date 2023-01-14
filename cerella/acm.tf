module "acm" {
  count          = var.acm-certificate-arn != "" ? 0 : 1
  source         = "./modules/acm"
  domain         = var.domain
  cluster-name   = var.cluster-name
  hosted-zone-id = var.hosted-zone-id
}

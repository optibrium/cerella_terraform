locals {
  output_for_optibrium = <<OUTPUTFOROPTIBRIUM

AccessKeys:
- Public Key / Access key:
${aws_iam_access_key.optibrium.id}
- Secret Key (Note the secret key is encrypted with the PGP key embedded in iam_user.tf)
${aws_iam_access_key.optibrium.encrypted_secret}

How to get Kubeconfig:
aws eks --region ${var.region} update-kubeconfig --name ${var.cluster-name} --profile <my_profile_created_with_above_keys>

The RDS endpoint:
postgresql://AAA:THISWILLBECHANGEDBYATHINGINSIDEKUBERNETES@${aws_rds_cluster.aaa.endpoint}/${aws_rds_cluster.aaa.database_name}

OUTPUTFOROPTIBRIUM
}

output "output_for_optibrium" {
  value = "\n\nPLEASE PROVIDE THIS TO OPTIBRIUM\n\n${base64encode(local.output_for_optibrium)}"
}


# uses localstack

provider "aws" {
  region                      = "us-west-1"
  access_key                  = "test"
  secret_key                  = "test"
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


# https://raw.githubusercontent.com/levmel/terraform-multidecoder-yaml_json/main/main.tf
# https://stackoverflow.com/questions/61122830/using-terraform-yamldecode-to-access-multi-level-element
# https://registry.terraform.io/modules/levmel/yaml_json/multidecoder/latest
module "ymlA" {
  source  = "levmel/yaml_json/multidecoder"
  version = "0.2.3"
  filepaths = ["data.yml"]
}

locals {

  vms = {for k,v in module.ymlA.files.data.virtualmachines : v.name => v  }

}


# # # https://registry.terraform.io/modules/0x022b/yaml-variables/local/latest
# # module "ymlB" {
# #   source  = "0x022b/yaml-variables/local"
# #   version = "1.0.1"
# #   filename = file("${path.root}/data.yml")
# # }

# output "a" {
#   value = local.vms
# }

# output b {
#   value = aws_ssm_parameter.ssmparams[*]
# }

# output "b" {
#   value = toset(module.ymlA.files.data["virtualmachines"])
# }


resource "aws_ssm_parameter" "ssmparams" {
  type = "String"
  for_each = local.vms
  name = each.value.name
  insecure_value = each.value.environ
}

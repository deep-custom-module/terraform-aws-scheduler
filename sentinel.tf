########################################################################
# Below block allows you to use outputs coming from TFE baseline of dedicated testing workspace.
# Do not change these values!
########################################################################

variable "terraform_module_git_repo" {} # Will be populated by the pipeline
variable "terraform_module_version" {}  # Will be populated by the pipeline

data "terraform_remote_state" "app_baseline" {
  backend = "remote"

  config = {
    organization = "core-prd"
    hostname     = "ptfe-crx5x8zy.deeptpe.pmicloud.xyz"

    workspaces = {
      name = "pmi-app-terratest-prd-baseline"
    }
  }
}

provider "aws" {
  region = data.terraform_remote_state.app_baseline.outputs.region
}

########################################################################
########################################################################
########################################################################

module "test" {

  # Required values
  source = "../"
  module_tags = {
    TerraformModuleGitRepo = var.terraform_module_git_repo
    TerraformModuleVersion = var.terraform_module_version
  }

  # (optional) Additional paramaters that have to be adjusted
  # Use of TFE baseline workspace outputs is supported
  # List of outputs available in ./baseline_outputs

  # ec2_launch_vpc_group = "greenfield"
  # env                  = "dev"
  # key_name             = "cm-rehost"
  # product_code         = "rehost"
  # vpc_id               = data.terraform_remote_state.app_baseline.outputs.vpc_id_primary
  # prv_subnet1          = data.terraform_remote_state.app_baseline.outputs.private_subnets_cidr_blocks_primary[0]
  # prv_subnet2          = data.terraform_remote_state.app_baseline.outputs.private_subnets_cidr_blocks_primary[1]

}
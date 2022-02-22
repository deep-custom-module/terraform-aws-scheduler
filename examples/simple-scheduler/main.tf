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
  source = "../../"
  tags = {
    TerraformModuleGitRepo = var.terraform_module_git_repo
    TerraformModuleVersion = var.terraform_module_version
  }
}
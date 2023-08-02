locals {
  slave_tags = {
    "role" = "slave"
  }

  webservers = ["webserver-01", "webserver-02"]
  owner      = "ishuar"

  common_tags = {
    "managed_by"  = "terraform"
    "github_repo" = "${local.owner}/ansible"
  }
}

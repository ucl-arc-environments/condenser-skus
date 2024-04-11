locals {
  yaml = yamldecode(file("skus-config-map.yml"))
}

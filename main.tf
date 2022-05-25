provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "lwac_certs" {
  source = "./modules/lwac_certs"
}

resource "helm_release" "admission_controller" {
  name       = "lacework-admission-controller"
  chart      = "https://github.com/lacework/helm-charts/raw/main/admission-controller-0.1.9.tgz"
  namespace  = "lacework"
  create_namespace = true
  force_update = true

  values = [
    "${templatefile("${path.module}/values.tftpl", {account = var.account, token = var.int_token})}"
  ]

  set {
    name  = "webhooks.caBundle"
    value = module.lwac_certs.ca_crt
  }

  set {
    name  = "certs.serverCertificate"
    value = module.lwac_certs.ac_crt
  }

  set {
    name  = "certs.serverKey"
    value = module.lwac_certs.ac_key
  }
  
}

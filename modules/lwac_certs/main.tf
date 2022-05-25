# roughly translated from this script https://github.com/lacework/helm-charts/blob/main/admission-controller/generate-certs.sh

resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = resource.tls_private_key.ca_key.private_key_pem

  subject {
    common_name  = "admission_ca"
  }

  validity_period_hours = (100000 * 24)

  allowed_uses = [
    "any_extended"
  ]

  is_ca_certificate = true
  
}

resource "tls_private_key" "admission_key" {
  algorithm = "RSA"
}

resource "tls_cert_request" "admission_csr" {
  private_key_pem = resource.tls_private_key.admission_key.private_key_pem

  subject {
    common_name  = "lacework-admission-controller.lacework.svc"
  }

  dns_names = [
      "lacework-admission-controller.lacework.svc",
      "lacework-admission-controller.lacework.svc.cluster.local",
      "admission.lacework-dev.svc",
      "admission.lacework-dev.svc.cluster.local"
  ]
}

resource "tls_locally_signed_cert" "admission_cert" {
  cert_request_pem   = resource.tls_cert_request.admission_csr.cert_request_pem
  ca_private_key_pem = resource.tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = resource.tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = (100000 * 24)

  allowed_uses = [
    "key_encipherment",
    "content_commitment",
    "digital_signature",
    "client_auth",
    "server_auth"
  ]
}
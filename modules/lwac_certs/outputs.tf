output "ca_crt" {
    value = base64encode(trimspace(resource.tls_self_signed_cert.ca_cert.cert_pem))
}

output "ac_crt" {
    value = base64encode(trimspace(resource.tls_locally_signed_cert.admission_cert.cert_pem))
}

output "ac_key" {
    value = base64encode(trimspace(resource.tls_private_key.admission_key.private_key_pem))
}
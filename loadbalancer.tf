resource "scaleway_lb_ip" "lb_ip" {}

resource "scaleway_lb" "lb01" {
  name  = format("%s-%s-%s", var.project_name, var.environment, "lb")
  ip_id = scaleway_lb_ip.lb_ip.id
  zone  = var.scw_zone
  type  = var.lb_type

  private_network {
    private_network_id = scaleway_vpc_private_network.pn01.id
    static_config      = ["192.168.0.100"]
  }

  depends_on = [
    scaleway_vpc_private_network.pn01,
    scaleway_vpc_public_gateway.pg01,
  ]
}

resource "scaleway_lb_backend" "backend" {
  lb_id            = scaleway_lb.lb01.id
  name             = "backend"
  forward_protocol = "http"
  forward_port     = var.lb_backend_backend_port
  server_ips       = [scaleway_vpc_public_gateway_dhcp_reservation.backend_dhcp_reservation.ip_address]

  health_check_http {
    uri    = "/healthcheck"
    method = "GET"
    code   = 200
  }

  depends_on = [
    scaleway_instance_server.backend_server
  ]
}

resource "scaleway_lb_backend" "frontend" {
  lb_id            = scaleway_lb.lb01.id
  name             = "frontend"
  forward_protocol = "http"
  forward_port     = var.lb_frontend_port
  server_ips       = [scaleway_vpc_public_gateway_dhcp_reservation.frontend_dhcp_reservation.ip_address]

  health_check_http {
    uri    = "/healthcheck"
    method = "GET"
    code   = 200
  }

  depends_on = [
    scaleway_instance_server.frontend_server
  ]
}

resource "scaleway_lb_frontend" "frt01" {
  lb_id        = scaleway_lb.lb01.id
  backend_id   = scaleway_lb_backend.frontend.id
  name         = "frontend"
  inbound_port = "443"
  certificate_ids = [
    scaleway_lb_certificate.cert01.id,
    scaleway_lb_certificate.cert02.id,
  ]
}

resource "scaleway_lb_route" "rt_backend" {
  frontend_id       = scaleway_lb_frontend.frt01.id
  backend_id        = scaleway_lb_backend.backend.id
  match_host_header = scaleway_domain_record.backend_dns_record.fqdn
}

resource "scaleway_lb_route" "rt_frontend" {
  frontend_id       = scaleway_lb_frontend.frt01.id
  backend_id        = scaleway_lb_backend.frontend.id
  match_host_header = scaleway_domain_record.frontend_dns_record.fqdn
}

resource "scaleway_lb_frontend" "frt02" {
  lb_id        = scaleway_lb.lb01.id
  backend_id   = scaleway_lb_backend.frontend.id
  name         = "http-redirect"
  inbound_port = "80"
}

resource "scaleway_lb_acl" "acl01" {
  frontend_id = scaleway_lb_frontend.frt02.id
  name        = "acl-http-redirect"
  description = "http to https redirect"
  index       = 0

  action {
    type = "redirect"
    redirect {
      type   = "scheme"
      target = "https"
      code   = 301
    }
  }

  match {
    ip_subnet = [
      "0.0.0.0/0",
    ]
  }
}

resource "scaleway_lb_certificate" "cert01" {
  lb_id = scaleway_lb.lb01.id
  name  = "cert-frontend"
  letsencrypt {
    common_name = scaleway_domain_record.frontend_dns_record.fqdn
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    scaleway_domain_record.frontend_dns_record,
  ]
}

resource "scaleway_lb_certificate" "cert02" {
  lb_id = scaleway_lb.lb01.id
  name  = "cert-backend"
  letsencrypt {
    common_name = scaleway_domain_record.backend_dns_record.fqdn
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    scaleway_domain_record.backend_dns_record,
  ]
}

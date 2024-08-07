resource "scaleway_vpc_private_network" "pn01" {
  name = format("%s-%s-%s", var.project_name, var.environment, "pn")
  tags = ["terraform"]
}

# DHCP Configuration for VPC Public Gateway
resource "scaleway_vpc_public_gateway_dhcp" "dhcp01" {
  subnet = "192.168.0.0/24"
}

resource "scaleway_vpc_public_gateway_ip" "gw01" {}

resource "scaleway_vpc_public_gateway" "pg01" {
  name  = format("%s-%s-%s", var.project_name, var.environment, "pg")
  type  = "VPC-GW-S"
  tags  = ["terraform"]
  ip_id = scaleway_vpc_public_gateway_ip.gw01.id
}

resource "scaleway_vpc_gateway_network" "gn01" {
  gateway_id         = scaleway_vpc_public_gateway.pg01.id
  private_network_id = scaleway_vpc_private_network.pn01.id
  dhcp_id            = scaleway_vpc_public_gateway_dhcp.dhcp01.id
  cleanup_dhcp       = true
  enable_masquerade  = true

  depends_on = [
    scaleway_vpc_private_network.pn01,
    scaleway_vpc_public_gateway_ip.gw01,
    scaleway_vpc_public_gateway.pg01,
  ]
}

# DHCP Reservations for Public Gateway, Backend/Frontend Servers
resource "scaleway_vpc_public_gateway_dhcp_reservation" "backend_dhcp_reservation" {
  gateway_network_id = scaleway_vpc_gateway_network.gn01.id
  mac_address        = scaleway_instance_private_nic.backend_pnic.mac_address
  ip_address         = "192.168.0.2"

  depends_on = [
    scaleway_vpc_public_gateway_dhcp.dhcp01,
    scaleway_vpc_gateway_network.gn01,
    scaleway_instance_private_nic.backend_pnic,
  ]
}

resource "scaleway_vpc_public_gateway_dhcp_reservation" "frontend_dhcp_reservation" {
  gateway_network_id = scaleway_vpc_gateway_network.gn01.id
  mac_address        = scaleway_instance_private_nic.frontend_pnic.mac_address
  ip_address         = "192.168.0.3"

  depends_on = [
    scaleway_vpc_public_gateway_dhcp.dhcp01,
    scaleway_vpc_gateway_network.gn01,
    scaleway_instance_private_nic.frontend_pnic,
  ]
}

# PAT Rules for SSH, HTTP, and HTTPS
resource "scaleway_vpc_public_gateway_pat_rule" "frontend_ssh" {
  gateway_id   = scaleway_vpc_public_gateway.pg01.id
  private_ip   = scaleway_vpc_public_gateway_dhcp_reservation.frontend_dhcp_reservation.ip_address
  private_port = 22
  public_port  = 2201
  protocol     = "tcp"

  depends_on = [
    scaleway_vpc_gateway_network.gn01,
    scaleway_vpc_private_network.pn01,
  ]
}

resource "scaleway_vpc_public_gateway_pat_rule" "backend_ssh" {
  gateway_id   = scaleway_vpc_public_gateway.pg01.id
  private_ip   = scaleway_vpc_public_gateway_dhcp_reservation.backend_dhcp_reservation.ip_address
  private_port = 22
  public_port  = 2202
  protocol     = "tcp"

  depends_on = [
    scaleway_vpc_gateway_network.gn01,
    scaleway_vpc_private_network.pn01,
  ]
}

resource "scaleway_vpc_public_gateway_pat_rule" "frontend_http" {
  gateway_id   = scaleway_vpc_public_gateway.pg01.id
  private_ip   = scaleway_vpc_public_gateway_dhcp_reservation.frontend_dhcp_reservation.ip_address
  private_port = 80
  public_port  = 80
  protocol     = "tcp"

  depends_on = [
    scaleway_vpc_gateway_network.gn01,
    scaleway_vpc_private_network.pn01,
  ]
}

resource "scaleway_vpc_public_gateway_pat_rule" "frontend_https" {
  gateway_id   = scaleway_vpc_public_gateway.pg01.id
  private_ip   = scaleway_vpc_public_gateway_dhcp_reservation.frontend_dhcp_reservation.ip_address
  private_port = 443
  public_port  = 443
  protocol     = "tcp"

  depends_on = [
    scaleway_vpc_gateway_network.gn01,
    scaleway_vpc_private_network.pn01,
  ]
}

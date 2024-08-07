resource "scaleway_instance_server" "backend_server" {
  name  = format("%s-%s-%s-%s", var.project_name, "back", var.environment, "ins")
  type  = var.backend_instance_type
  image = "docker"

  tags = ["terraform"]

  root_volume {
    size_in_gb  = var.backend_instance_root_volume_size_in_gb
    volume_type = "b_ssd"
  }
}

resource "scaleway_instance_server" "frontend_server" {
  name  = format("%s-%s-%s-%s", var.project_name, "front", var.environment, "ins")
  type  = var.frontend_instance_type
  image = "docker"

  tags = ["terraform"]

  root_volume {
    size_in_gb  = var.frontend_instance_root_volume_size_in_gb
    volume_type = "b_ssd"
  }
}


# Private NICs for Backend and Frontend Servers
# A Private NIC is the network interface that connects an Instance to a Private Network. An Instance can have multiple private NICs at the same time, but each NIC must belong to a different Private Network.
resource "scaleway_instance_private_nic" "backend_pnic" {
  server_id          = scaleway_instance_server.backend_server.id
  private_network_id = scaleway_vpc_private_network.pn01.id

  depends_on = [
    scaleway_instance_server.backend_server,
    scaleway_vpc_gateway_network.gn01,
    scaleway_vpc_private_network.pn01,
  ]
}

resource "scaleway_instance_private_nic" "frontend_pnic" {
  server_id          = scaleway_instance_server.frontend_server.id
  private_network_id = scaleway_vpc_private_network.pn01.id

  depends_on = [
    scaleway_instance_server.frontend_server,
    scaleway_vpc_gateway_network.gn01,
    scaleway_vpc_private_network.pn01,
  ]
}

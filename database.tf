locals {
  enable_resource_creation = var.environment == "staging" || var.environment == "production" ? 1 : 0
}


resource "scaleway_rdb_instance" "db_instance" {
  count         = local.enable_resource_creation
  name          = format("%s-%s-%s", var.project_name, var.environment, "pgdb")
  node_type     = var.db_instance_node_type
  engine        = "PostgreSQL-15"
  is_ha_cluster = false
  user_name     = var.db_instance_admin_user_name
  password      = var.db_instance_admin_password

  volume_type       = "bssd"
  volume_size_in_gb = var.db_instance_volume_size_in_gb

  disable_backup            = false
  backup_schedule_frequency = 24 # every day
  backup_schedule_retention = 7  # keep it one week

  private_network {
    ip_net = "192.168.0.254/24" #pool high
    pn_id  = scaleway_vpc_private_network.pn01.id
  }

  depends_on = [
    scaleway_vpc_gateway_network.gn01,
    scaleway_vpc_private_network.pn01,
  ]
}

resource "scaleway_rdb_acl" "private_network_acl" {
  count       = local.enable_resource_creation
  instance_id = scaleway_rdb_instance.db_instance[0].id
  acl_rules {
    ip          = "192.168.0.0/24"
    description = "private_network"
  }
}

resource "scaleway_rdb_database" "db" {
  count       = local.enable_resource_creation
  instance_id = scaleway_rdb_instance.db_instance[0].id
  name        = var.db_instance_database_name
}


resource "scaleway_rdb_user" "db_user" {
  count       = local.enable_resource_creation
  instance_id = scaleway_rdb_instance.db_instance[0].id
  name        = var.db_instance_user_name
  password    = var.db_instance_password
  is_admin    = false

  depends_on = [
    scaleway_rdb_database.db,
    scaleway_rdb_instance.db_instance,
  ]
}

resource "scaleway_rdb_privilege" "db_admin_user_privilege" {
  count         = local.enable_resource_creation
  instance_id   = scaleway_rdb_instance.db_instance[0].id
  user_name     = var.db_instance_admin_user_name
  database_name = scaleway_rdb_database.db[0].name
  permission    = "all"

  depends_on = [
    scaleway_rdb_instance.db_instance,
    scaleway_rdb_database.db,
  ]
}

resource "scaleway_rdb_privilege" "db_user_privilege" {
  count         = local.enable_resource_creation
  instance_id   = scaleway_rdb_instance.db_instance[0].id
  user_name     = var.db_instance_user_name
  database_name = scaleway_rdb_database.db[0].name
  permission    = "all"

  depends_on = [
    scaleway_rdb_instance.db_instance,
    scaleway_rdb_database.db,
    scaleway_rdb_user.db_user,
  ]
}

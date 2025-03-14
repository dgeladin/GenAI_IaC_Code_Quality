# main.tf
module "compute" {
  source = "./modules/compute"

  vpc_zone_identifier                   = var.vpc_zone_identifier
  min_size                              = var.min_size
  max_size                              = var.max_size
  desired_capacity                      = var.desired_capacity
  on_demand_base_capacity               = var.on_demand_base_capacity
  on_demand_percentage_above_base       = var.on_demand_percentage_above_base_capacity
  instance_profile                      = var.instance_profile
  security_group_ids                    = [module.network.web_server_sg_id]
  vpc_id                                = module.network.vpc_id
}

module "network" {
  source = "./modules/network"
  vpc_cidr_block = var.vpc_cidr_block
}


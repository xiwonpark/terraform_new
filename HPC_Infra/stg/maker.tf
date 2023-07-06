module "vpc" {
  source = "../module/vpc"

  name     = "sw-tf-vpc"
  vpc_cidr = "10.0.0.0/16"
  region   = "ap-northeast-2"
  az       = ["a", "c"]

  public_subnets  = ["10.0.10.0/24", "10.0.11.0/24"]
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]

  tags = {
    ManagedByTerraform = "true"
    Creator            = "Siwon"
    Email              = "swpark@ezcom.co.kr"
    Module             = "vpc"
    ezcom              = "Cost By TF"
  }
}

module "ec2" {
  source = "../module/ec2"

  name                 = "sw-tf-ec2"
  bastion_ip           = "10.0.10.21"
  awx_controller_ip    = "10.0.0.20"
 # public_key_path      = "~/.ssh/id_rsa.pub"
 # private_key_path     = "~/.ssh/id_rsa"
  public_subnets_id_a  = module.vpc.public_subnets_id_a
  public_subnets_id_c  = module.vpc.public_subnets_id_c
  private_subnets_id_a = module.vpc.private_subnets_id_a
  private_subnets_id_c = module.vpc.private_subnets_id_c
  sg                   = module.vpc.sg
  target_group_vnc     = module.vpc.target_group_vnc
  target_group_awx     = module.vpc.target_group_awx

  instance_type = ["t3.micro", "t3.large", "t3.xlarge"]
  awx_nodes     = ["ldapserver", "vncserver", "lsf_master", "lsf_node01"]
  awx_nodes_ip  = ["10.0.0.21", "10.0.0.22", "10.0.0.23", "10.0.0.24"]

  ami = {
    cent79 = "ami-09e2a570cb404b37e"
    cent83 = "ami-02ab944d7e31b1074"
  }

  tags = {
    ManagedByTerraform = "true"
    Creator            = "Siwon"
    Email              = "swpark@ezcom.co.kr"
    Module             = "ec2"
    ezcom              = "Cost By TF"
  }
}
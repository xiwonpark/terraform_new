module "vpc" {
  source = "../module/vpc"

  name     = "sw-tf-vpc"
  vpc_cidr = "10.0.0.0/16"
  region   = "ap-northeast-2"
  az       = ["a", "c"]
  bastion_id = module.ec2.bastion_id

  public_subnets  = ["10.0.30.0/24", "10.0.31.0/24"]
  private_subnets = ["10.0.20.0/24", "10.0.21.0/24"]

  tags = {
    ManagedByTerraform = "true"
    Creator            = "Siwon"
    Email              = "swpark@ezcom.co.kr"
    Module             = "vpc"
    ezcom              = "Cost By TF"
    project            = "EKS"
  }
}

module "ec2" {
  source = "../module/ec2"

  name                 = "sw-tf-ec2"
  bastion_ip           = "10.0.30.21"
  public_subnets_id_a  = module.vpc.public_subnets_id_a
  public_subnets_id_c  = module.vpc.public_subnets_id_c
  private_subnets_id_a = module.vpc.private_subnets_id_a
  private_subnets_id_c = module.vpc.private_subnets_id_c
  sg                   = module.vpc.sg
  

  instance_type = ["t3.micro", "t3.medium", "t3.xlarge"]
  
  ami = {
    cent79 = "ami-09e2a570cb404b37e"
    cent83 = "ami-02ab944d7e31b1074"
    ubuntu22_04 = "ami-0e38c97339cddf4bd"
  }

  tags = {
    ManagedByTerraform = "true"
    Creator            = "Siwon"
    Email              = "swpark@ezcom.co.kr"
    Module             = "ec2"
    ezcom              = "Cost By TF"
    project            = "EKS"
  }
}

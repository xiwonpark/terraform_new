module "foundry" {
  source = "./project"
  name     = "hyc-foundry"
  foundry_01_sn = "subnet-0a5d20c1144da3c62"
  sg           = "sg-09292891d5ecc93d7"

  instance_type = ["t3.micro", "t3.medium", "t3.large", "t3.xlarge"]
  A_project_ip       = [for line in split("\n", file("./project/DNS/A_project_DNS.txt")) : split(" ", line)[0]]
  A_project_hostname = [for line in split("\n", file("./project/DNS/A_project_DNS.txt")) : split("   ", line)[1]]


  ami = {
    RHEL79 = "ami-09e2a570cb404b37e"
    RHEL83 = "ami-02ab944d7e31b1074"
  }

  tags = {
    ManagedByTerraform = "true"
    Creator            = "Siwon"
    Email              = "swpark@ezcom.co.kr"
    Module             = "foundry"
    project            = "TF PoC"
  }
}

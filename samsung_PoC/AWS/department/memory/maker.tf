module "memory" {
  source       = "./project"
  name         = "hyc-memory"
  memory_01_sn = "subnet-0eb3b82b678c8e550"
  memory_02_sn = "subnet-046e1f87f44468849"
  sg           = "sg-09292891d5ecc93d7"

  instance_type = ["t3.micro", "t3.medium", "t3.large", "t3.xlarge"]

  B_project_ip       = [for line in split("\n", file("./project/DNS/B_project_DNS.txt")) : split(" ", line)[0]]
  B_project_hostname = [for line in split("\n", file("./project/DNS/B_project_DNS.txt")) : split("   ", line)[1]]

  C_project_ip       = [for line in split("\n", file("./project/DNS/C_project_DNS.txt")) : split(" ", line)[0]]
  C_project_hostname = [for line in split("\n", file("./project/DNS/C_project_DNS.txt")) : split("   ", line)[1]]

  ami = {
    RHEL79 = "ami-09e2a570cb404b37e"
    RHEL83 = "ami-02ab944d7e31b1074"
  }

  tags = {
    ManagedByTerraform = "true"
    Creator            = "Siwon"
    Email              = "swpark@ezcom.co.kr"
    Module             = "memory"
    project            = "TF PoC"
  }
}

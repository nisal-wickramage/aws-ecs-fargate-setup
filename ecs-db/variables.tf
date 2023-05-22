variable "subnet_ids" {
  type = list(string)
  description = "DB subnets"
  default = [ "subnet-02204153b2d827740", "subnet-0b7e55b5b031798f7" ]
}
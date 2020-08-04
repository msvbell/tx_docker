provider "vcd" {
  user                 = "administrator"
  password             = "QV!57@ni@22R5@"
  auth_type            = "integrated"
  org                  = "compas-plus-fr4"
  url                  = "https://fr4.m1cloud.ru/api"
  max_retry_timeout    = 10
}

# Create a new network in some organization and VDC
resource "vcd_vapp" "test" {
  name = "test"
}
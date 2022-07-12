### PROJECT VARIABLES ###
variable "Env" {} #
variable "main_vpc" {} #
variable "dmz_subnet_1" {} #
variable "dmz_subnet_2" {} #
variable "cidr_vpc" {} #
variable "log_group" {} #
variable "deployment_minimum_healthy_percent" {} #
variable "deployment_maximum_percent" {} #
variable "min_capacity" {} #
variable "max_capacity" {} #
variable "container_cpu" {} #
variable "container_memory" {} #
variable "container_memoryReservation" {} #
variable "ecr_registry_type" {} #
variable "region" {} #
variable "waycarbon-image" {
  default = "1.0"
}

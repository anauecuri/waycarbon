Env = "prd" #
  
main_vpc =   "vpc-626b821f" #
  
dmz_subnet_1 =   "subnet-7d690530" #
  
dmz_subnet_2 =   "subnet-45f92264" # 
  
cidr_vpc =   "172.31.0.0/16" # 
  
deployment_minimum_healthy_percent =   "0"  #
  
deployment_maximum_percent =   "100" #   
  
min_capacity =   "1"  #
  
max_capacity =   "10"  #

log_group = "/ecs/Waycarbon-Svc-Logs" #

container_cpu =   "256" # 
  
container_memory =   "1024"  #
  
container_memoryReservation =   "1024" # 
  
ecr_registry_type =   "-snapshop" # 
   
region = "us-east-1" # 

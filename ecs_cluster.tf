resource "aws_ecs_cluster" "ecs_cluster" {
  name = "fargate-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "ecs_fargate_provider" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}
output "lb_hostname" {
  value = aws_lb.main.dns_name
}

output "lb_smtp_hostname" {
  value = aws_lb.smtp.dns_name
}

output "lb_zone_id" {
  value = aws_lb.main.zone_id
}

output "lb_smtp_zone_id" {
  value = aws_lb.smtp.zone_id
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "aws_load_balancer" {
  value = aws_lb.main.arn
}
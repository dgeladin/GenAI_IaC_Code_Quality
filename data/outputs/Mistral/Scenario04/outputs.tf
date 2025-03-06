output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.app_lb.dns_name
}

output "blue_asg_name" {
  description = "The name of the blue Auto Scaling Group"
  value       = aws_autoscaling_group.blue_asg.name
}

output "green_asg_name" {
  description = "The name of the green Auto Scaling Group"
  value       = aws_autoscaling_group.green_asg.name
}

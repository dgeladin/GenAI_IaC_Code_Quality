output "web_server_asg_name" {
  description = "The name of the web server ASG."
  value       = aws_autoscaling_group.web_server_asg.name
}

output "web_server_lb_dns_name" {
  description = "The DNS name of the web server load balancer."
  value       = aws_lb.web_server_lb.dns_name
}

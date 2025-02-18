# File: locals.tf
locals {
  # Combine common tags with ASG-specific tags
  combined_tags = merge(var.tags, var.asg_tags)
  
  # Convert the tags map to ASG tag list format
  asg_tags = [
    for key, value in local.combined_tags : {
      key                 = key
      value              = value
      propagate_at_launch = true
    }
  ]
  
  # Common name prefix for all resources
  name_prefix = "${var.tags["Project"]}-${var.tags["Environment"]}"
}
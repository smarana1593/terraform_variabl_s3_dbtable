resource "aws_launch_template" "asg_template" {
  name_prefix   = "asg_lt_example"
  image_id      = "${var.ami}"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = [aws_security_group.dev-sg.id]
   lifecycle {
     create_before_destroy = true
   }

   tags = {
    Name = "asg-lt_example"
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "asg"
  min_size                  = "${var.autoscaling_group_min_size}"
  max_size                  = "${var.autoscaling_group_max_size}"
  desired_capacity          = 2
  health_check_grace_period = 5
  health_check_type         = "ELB"
  vpc_zone_identifier       = [aws_subnet.public.id,aws_subnet.private.id]
  launch_template {
    id      = aws_launch_template.asg_template.id
    version = "$Latest"
  }

}

resource "aws_autoscaling_policy" "avg_cpu_policy_greater" {
  name                   = "avg-cpu-policy-greater"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.id
  # CPU Utilization is above 50
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }

}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.front-end.arn
}
~

output "websiteurl" {
    value = "http://${aws_alb.app-lb.dns_name}"  #string icinde oldugu icin $
  
}
output "jenkins_master_public_ip" {
  description = "Public IP address of the Jenkins Master EC2 instance"
  value       = aws_instance.jenkins_master.public_ip
}


output "jenkins_agent_public_ip" {
  description = "Public IP address of the Jenkins Agent EC2 instance"
  value       = aws_instance.jenkins_agent.public_ip
}


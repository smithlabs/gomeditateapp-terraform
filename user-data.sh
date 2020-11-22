#!/bin/bash

# Update the system
sudo yum update -y

# Installing Docker on Amazon Linux 2
# Ref: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html
sudo amazon-linux-extras install -y docker
sudo yum install -y docker git
sudo service docker start

# Add the ec2-user to the docker group so you can execute Docker commands without using sudo
# Useful if you want to SSH into the machine as ec2-user and want to run `docker ps`
sudo usermod -a -G docker ec2-user

# The current SSH session for the ec2-user will not be in the Docker group until they reconnect
# Use sudo below so this deploy script will work properly.

# Run the docker container in detached mode and map port 8080 on the host to 8080 in the container
# This is required so it can be accessed by a browser or external load balancer/reverse proxy.
sudo docker run --restart=always --name app -d -p 8080:8080 smithlabs/gomeditateapp:pr_build

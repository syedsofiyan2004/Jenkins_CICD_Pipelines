# Jenkins Assignment
## In this Assignment we are Accessing Jenkins via an EC2 Instance

Initially we have to create two EC2 Instances from which one is named as "Master Node" and other is named as "Agent node" we are going make a connection Establishment between Master and Agent node for their communication and it is also a conventional way to follow the security practices in an Organization

I have created two EC2 instances using a terraform code:

The **main.tf** file have the code for creating two instances:
```tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "jenkins-syed_sofiyan-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "jenkins-syed_sofiyan-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "jenkins-syed_sofiyan-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "jenkins-syed_sofiyan-rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "jenkins_master_sg" {
  name        = "jenkins-master-sofiyan-sg"
  description = "Allow SSH, HTTP, HTTPS and custom TCP 8080"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sofiyan-master-sg"
  }
}
resource "aws_security_group" "jenkins_agent_sg" {
  name        = "jenkins-sofiyan-agent-sg"
  description = "Allow only SSH"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-agent-sofiyan-agent-sg"
  }
}

resource "aws_instance" "jenkins_master" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.jenkins_master_sg.id]
  associate_public_ip_address = true
  key_name                   = var.key_pair_name

  tags = {
    Name = "Jenkins-Master-sofiyan-ec2"
  }
}

resource "aws_instance" "jenkins_agent" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.jenkins_agent_sg.id]
  associate_public_ip_address = true
  key_name                   = var.key_pair_name

  tags = {
    Name = "Jenkins-sofiyan-Agent-EC2"
  }
}
```

Now after executing this file using ```terraform apply``` the instances have been created:

![Screenshot 2025-06-23 160339](https://github.com/user-attachments/assets/538f70e4-06c5-4f50-a395-1b3924868d6a)

As we can see in the image we have created two Instances one for Master Node where we will be running Jenkins and one is agent node for offloading the jobs of Master node like the labels which we provide for our pipeline to run like Linux Docker Nodejs it will be offloaded to agent node to make Master node more efficient and also decrease the work it should do which result in faster response.

Now after creating both the instances SSH into both the instances:

Master Node instance:
![Screenshot 2025-06-23 160433](https://github.com/user-attachments/assets/4345d12d-da8d-4529-a535-dd8f7b205640)

Agent node instance:
![Screenshot 2025-06-23 160627](https://github.com/user-attachments/assets/a43eb2a0-6710-4356-bfeb-373464adfabd)

After SSH into it we need to Download certain Packages in bot the instances to proceed further,
 Let's dive into Master EC2 instance where we have to run jenkins:
 
I have typed the following commands to proceed with downloading the jenkins in our Master EC2 Instance:
```bash
sudo yum update –y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
```
These Commands will pull Jenkins repository for you in Amazon Linux Machine

Now we need to Download java too for running jenkins Application so we also need to download java in our Master Node:

![image](https://github.com/user-attachments/assets/1f505d9b-fa25-4c6c-9256-b8c41b343c82)
![image](https://github.com/user-attachments/assets/ef789f2c-35d8-4da9-8d71-dd06421f6b2c)

I have Typed the following command to download Java:
```bash
sudo yum install java-17-amazon-corretto -y
```
![image](https://github.com/user-attachments/assets/95ba453a-c64c-42f9-8bd7-b7a86b340833)
![image](https://github.com/user-attachments/assets/32c430cc-7027-4d65-917c-fc0972d2ade5)

Now we have to install and Enable Jenkins:
```bash
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
```
![image](https://github.com/user-attachments/assets/8a81b445-53b0-4d8b-9308-325f17764603)
![image](https://github.com/user-attachments/assets/827450bc-8c56-4dfe-9b7b-745bc51b57f5)
![image](https://github.com/user-attachments/assets/c2767f43-0b0e-4dfd-8217-fe75313d6937)

We have installed and enabled jenkins now we have to access it on **port(8080):**
![image](https://github.com/user-attachments/assets/083946ae-ccda-422b-84c3-ca6b3a791fc5)

It looks something like this but we need to type the Initial Password to Access the Application so we can go into the password directory to get the Password:
```bash
sudo cat /var/jenkins_home/secrets/initialAdminPassword
```
this will reveal the password and you can proceed further:
![image](https://github.com/user-attachments/assets/dc1d04a9-1423-4f65-a6ff-2a0c686f93d1)

After typing the password and going to into jenkins it will start downloading the resources:
![image](https://github.com/user-attachments/assets/9716cae4-31ad-4183-8a39-b1e287558ccd)

After the resources are downloaded the UI looks something like this:
![Screenshot 2025-06-23 161053](https://github.com/user-attachments/assets/bcaa2450-db42-4d4d-a03b-ad154a5d8da7)

Now we have to establish connection between Master node and the agent node we can do this by doing Key exchange basically using the public key and a private key:

Before creating a key we need to gain shell access of our Jenkins application:
```bash
su -s /bin/bash jenkins
```
We can create a public key in our Master EC2 Instance by typing this command:
```bash
ssh-keygen -t rsa
```
This command will generate a public key and store its content in this **/var/lib/jenkins/.ssh/id_rsa** directory

Now we also need to copy the contents of the public key cause we need to copy and paste it in the agent node so lets view the key contents and copy it:
```bash
sudo cat /var/lib/jenkins/.ssh/id_rsa.pub
```
this will display the key contents and copy it for now

![Screenshot 2025-06-23 160530](https://github.com/user-attachments/assets/a5a23b28-22d7-42f4-9630-2622417833b7)

Now go to the Agent EC2 Instance and just type this command:
```bash
echo "PASTE_THE_PUBLIC_KEY_FROM_MASTER_HERE" >> /home/ec2-user/.ssh/authorized_keys
```
instead of **PASTE_THE_PUBLIC_KEY_FROM_MASTER_HERE** we have to paste the actual key contents which we copied earlier and we have to do this in the Agent node EC2 machine
![image](https://github.com/user-attachments/assets/828f0305-7b36-4a97-88e2-60849bcfd1f2)

After copying verify whether its copied there or not by typing cat command:
```bash
sudo cat /home/ec2-user/.ssh/authorized_keys
```
![Screenshot 2025-06-23 162220](https://github.com/user-attachments/assets/051485fc-8fd3-4028-87c2-06cd6262c07d)

before creating a node we need to add credentials and other configuration stuff such as:
![image](https://github.com/user-attachments/assets/cddd747f-a91b-430c-be50-1abe4605aefa)
![image](https://github.com/user-attachments/assets/02773696-9ce3-4fac-8858-179f22099ad1)

The Private key which we have to paste here is from master node EC2 Instance just type this command to get the private key:
```bash
sudo cat /var/lib/jenkins/.ssh/id_rsa
```
![Screenshot 2025-06-23 160557](https://github.com/user-attachments/assets/7c902941-0d4f-4e6b-a828-13b33926fc7f)

Paste this key in the private key section of Credentials and create the credentials
![image](https://github.com/user-attachments/assets/4361c56e-1863-4f7e-834a-1afc498d4e0d)


Now we have to create a Node in Jenkins to create jobs and other stuff to proceed further:
![Screenshot 2025-06-23 162256](https://github.com/user-attachments/assets/4e15ee31-ff89-4cf4-98d5-9158314160db)
![Screenshot 2025-06-23 162308](https://github.com/user-attachments/assets/4090c0aa-a1b7-4822-af49-33db5aca3e1a)
![Screenshot 2025-06-23 162315](https://github.com/user-attachments/assets/ff41a181-212a-477b-8855-65d40838f8b9)

Name of the Node can be anything and for remote Workspace i have used this **/home/ec2-user/jenkins-workspace** this is create all the jobs in this directory of the Master node, The labels is what are the jobs you wanna run for now i have added **linux docker nodejs**
Launch method should be Launch agents via SSH and in that part the host should be the **private IP address of the Agent Node** credentials is the one which we added earlier which is **ec2-user**
and for Host key verification Strategy lets go for non-Verifying for now as it is normal assigment but this is not advised for Disk Space keep Everything zero for now as we are using Amazon Linux machine now press on save and apply after saving and apply we will see that the node is in connected state 

![Screenshot 2025-06-23 162404](https://github.com/user-attachments/assets/24292b78-0ed8-4c2b-83ee-f155ec8dc1f4)
![Screenshot 2025-06-23 162331](https://github.com/user-attachments/assets/9bd5dead-c885-4541-ab0d-7bc03ba19922)

Now are node is online so we can proceed with creating our first job which is a pipeline and verify whether its working or not.
But first we need to create an **app.js** and also we require **package.json** too:

###### app.js
```js
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello from Syed Sofiyan this is my Node.js App! Version 1');
});

app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});
```
##### package.json
```js
{
  "name": "jenkins-aws-demo",
  "version": "1.0.0",
  "description": "Simple app for Jenkins demo",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "echo \"Tests passed!\" && exit 0"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```
Alternatively we need to install git and nodejs in our both EC2 instances

![Screenshot 2025-06-23 165744](https://github.com/user-attachments/assets/f87d49e5-0ef2-4c11-87a6-8c6509e83752)
![Screenshot 2025-06-23 165756](https://github.com/user-attachments/assets/f2f006a8-ef25-4f25-84b9-65d6b7b373bd)

now we have to Write a Jenkins file for our pipeline which looks like this:
```Jenkinsfile
pipeline {
    agent { label 'linux' }

    stages {
        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }
        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }
    }
}
```
As we can see we have used the label linux which means this pieline is running on linux and the stages are the sequence we are running the commands like first Install Dependencies and then we need to run the tests which we are doing via pipeline

now after writing this pipeline in a file named Jenkinsfile we can now push our repository in the github.

![Screenshot 2025-06-23 164003](https://github.com/user-attachments/assets/155a346b-7316-44c4-99f1-684e8146ae0f)

We have pushed our repository now its the time to create our first pipeline:
![Screenshot 2025-06-23 165152](https://github.com/user-attachments/assets/3b8266d0-a82d-41fb-b8e3-06173d54cfda)

i have created a pipeline named **sofiyan-first-pipeline** now we have to set up the configurations:

![Screenshot 2025-06-23 165458](https://github.com/user-attachments/assets/4adddd9b-c1ec-46d1-88df-796c689190f6)
![Screenshot 2025-06-23 165523](https://github.com/user-attachments/assets/938b1c53-ead0-4895-a8d0-118b898b3465)
![Screenshot 2025-06-23 165537](https://github.com/user-attachments/assets/da0489c7-d1f6-4976-a070-e90aff9d4a0a)

We have added Git as SCM for our pipeline and have given our GitHub Repository link and in branches to build we gave **main** branch as we have pushed our repository in our main branch and then for the script path we have given Jenkinsfile as we have written our Pipeline in the Jenkinsfile and click on save and apply so see the magic of Automation:
![Screenshot 2025-06-23 165615](https://github.com/user-attachments/assets/ac1ceb19-46ea-423d-89e5-16d66e0b8219)

We should Press on Build Now to start the build:
![Screenshot 2025-06-23 171949](https://github.com/user-attachments/assets/daaddcbf-aaaa-476f-acf7-bd47f4c5e7ed)
![Screenshot 2025-06-23 172009](https://github.com/user-attachments/assets/2735aaa1-10db-4b49-960e-a94ec3cdc7a3)

As we can see the build is successful which means the pipeline was executed and the automation was done

## This is the final deliverable of this Assignment

Now we have to do a cleanup Job now by executing this command all the resoutces created will be deleted:
```bash
terraform destroy
```
![Screenshot 2025-06-23 172406](https://github.com/user-attachments/assets/f5445041-ec13-4419-85f7-3dc6c7cca18e)
![Screenshot 2025-06-23 172431](https://github.com/user-attachments/assets/b7e59525-9930-4e98-8c5d-1b1c574ba4c1)


# END OF ASSIGNMENT

























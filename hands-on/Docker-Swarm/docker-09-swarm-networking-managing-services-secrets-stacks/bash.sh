#! /bin/bash
echo "alias d='/usr/bin/docker'" >> /home/ec2-user/.bashrc
echo 'export PS1="\[\e[36m\]\u\[\e[m\]@\h-\w:\[\e[31m\]\\$\[\e[m\] "' >> /home/ec2-user/.bash_profile
yum update -y
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
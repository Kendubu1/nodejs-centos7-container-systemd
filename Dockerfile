FROM centos:7

#install node/npm
RUN (curl -sL https://rpm.nodesource.com/setup_12.x | bash -) \
  && yum clean all -y \
  && yum update -y \
  && yum install -y nodejs \
  && yum -y install initscripts \
  && yum autoremove -y \
  && yum clean all -y \
  && npm install npm --global

#install ssh & configure default azure login 
RUN yum install -y openssh-server \
  && echo "root:Docker!" | chpasswd

#add sshd config, exporse required port & generate key 
COPY sshd_config /etc/ssh/sshd_config
COPY startup.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/startup.sh
RUN ssh-keygen -A
EXPOSE 2222

#script to execute the systemctl commands without enabling systemd
# used to avoid mounting the required cgroup volume at startup
# https://github.com/gdraheim/docker-systemctl-replacement
COPY systemctl.py /usr/bin/systemctl
RUN chmod a+x /usr/bin/systemctl

#copy and build the node application/expose port
WORKDIR /usr/local/app
COPY app /usr/local/app
RUN npm install 
ENV PORT 80
EXPOSE 80

#startup script for application
ENTRYPOINT ["/usr/local/bin/startup.sh"]

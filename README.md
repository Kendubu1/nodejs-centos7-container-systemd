# Centos7 Nodejs container w/ SSH Enabled (2 Methods)
- This is a proof of concept sample for deploying a Centos container with SSH enabled on Azure App Services.
- This repo has two possible startup configurations depending on the preferred approach & leverages a startup script as the entry point, which allows us to prep our environment & start sshd in addition to our application. 


## Method 1(default) - "Systemd" Approach - startup.sh
- Enabling systemd with centos/docker requires the need to run the container in priviledged mode & mount a cgroupe volume drive.[More Info](https://developers.redhat.com/blog/2014/05/05/running-systemd-within-docker-container)
- We avoid this with a script to replace our systemctl which allows us to execute service management commands without the need of [enabling systemd](https://hub.docker.com/r/centos/systemd).
```bash
#Dockerfile snippet
COPY systemctl.py /usr/bin/systemctl
RUN chmod a+x /usr/bin/systemctl
```
## Method 2 - Running SSHD as a non-daemon process - startup2.sh
- If there is no need to manage any services/daemons then we can pass the -D flag while starting [sshd](https://man.openbsd.org/sshd) & appending our application startup command.
- [sshd](https://man.openbsd.org/sshd) will not detech & will not become a daemon 
- 📝  See method2 branch
```bash
#startup.sh snippet
echo "Starting SSH & Node..."
/usr/sbin/sshd -D&
npm start
```

## Building the container locally | localhost:4000
⚠ Make sure startup.sh & systemctl.py are saved with LF line-endings on your local machine before building in docker.
```docker
$ cd nodejs-centos7-container-systemd
$ docker build -t <tag-name> .
$ docker run -d -p 4000:80 <tag-name>
```

## Push to Registry 
⚠ Assumed the tag is "nodejs-centos7-container-systemd" & registry username is "Azure"
```
$ docker login
$ docker tag dotnet-ssh Azure/nodejs-centos7-container-systemd
$ docker push Azure/nodejs-centos7-container-systemd
```



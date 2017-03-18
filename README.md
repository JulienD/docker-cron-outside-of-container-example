# Creating a container in order to execute jobs on other containers

This is an example of how to create a docker container to run scheduled commands using the crontab on other containers.

If you just need a container to run jobs that do not need to interact with additional containers, I recommend you to have a look at my other repository [docker-cron-example](https://github.com/JulienD/docker-cron-example).

Also known as DooD (Docker outside of Docker), I have implemented this by the past when playing with continuous integration systems that used docker to build applications based on pull-requests. The basic idea of DooD is to access the host’s Docker installation from within the container. Basically, we link the docker socket (/var/run/docker.sock) from the host to the cron container using the -v flag.

You can build the image using the following commands:

```
$ docker build -t docker-cron-ooc-example .
```

You can run the container like this:

```
$ docker run -it \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
--name my-docker-cron-ooc \
docker-cron-ooc-example
```

Few minutes after having started the container you should see something similar to this:

```
crond: crond (busybox 1.24.2) started, log level 8
crond: USER root pid  12 cmd docker ps >> /var/log/cron/cron.log 2>&1
CONTAINER ID        IMAGE                     COMMAND             CREATED             STATUS              PORTS               NAMES
161557771d32        docker-cron-ooc-example   "/run-crond.sh"     9 seconds ago       Up 8 seconds                            my-docker-cron-ooc
crond: USER root pid  19 cmd docker ps >> /var/log/cron/cron.log 2>&1
CONTAINER ID        IMAGE                     COMMAND             CREATED              STATUS              PORTS               NAMES
161557771d32        docker-cron-ooc-example   "/run-crond.sh"     About a minute ago   Up About a minute                       my-docker-cron-ooc
crond: USER root pid  27 cmd docker ps >> /var/log/cron/cron.log 2>&1
CONTAINER ID        IMAGE                     COMMAND             CREATED             STATUS              PORTS               NAMES
161557771d32        docker-cron-ooc-example   "/run-crond.sh"     2 minutes ago       Up 2 minutes                            my-docker-cron-ooc
crond: USER root pid  33 cmd docker ps >> /var/log/cron/cron.log 2>&1
CONTAINER ID        IMAGE                     COMMAND             CREATED             STATUS              PORTS               NAMES
161557771d32        docker-cron-ooc-example   "/run-crond.sh"     3 minutes ago       Up 3 minutes                            my-docker-cron-ooc
```

## Using environment variables

The following command included in [run-crond.sh](run-crond.sh) loads all the environment variables, gets the one starting with ENV_, combine them at the top of the /tmp/crontab file and finally move the result to /etc/cron.d/crontab

```
env | egrep '^ENV_' | cat - /tmp/crontab > /etc/cron.d/crontab
```

Add environment variables to the docker run command using the -e flag like this. You should be able to use them in your script.

```
$ docker run -it -e ENV_NAME=f00 docker-cron-ooc-example
```

## Accessing to the logs

You can access to the crontab output by running docker logs on your container

```
$ docker logs <container_name>
```

## The Dockerfile

```
FROM gliderlabs/alpine:3.5
MAINTAINER "Julien Dubreuil"
RUN apk update && apk add --no-cache docker (see the Notes section)

COPY crontab /tmp/crontab

COPY run-crond.sh /run-crond.sh
RUN chmod -v +x /run-crond.sh

RUN mkdir -p /var/log/cron && touch /var/log/cron/cron.log

CMD ["/run-crond.sh"]
```
1. The FROM command specify our base image. It used a alpine on steroids image as our base image.
2. Next, we copy the crontab file to the /tmp directory of the container in order to make it available as declared in the run-crond.sh file.
3. Then, we copy the crontab run script to the container and make it executable.
4. We Create a default log file for the cron job.
5. Finally, we specify the command that container will execute on startup.

## Notes

Normally you can get rid of the docker installation inside the cron container by linking the docker binary file from the host to the container. Unfortunately after several tries I haven't been able to achieve it on my mac (maybe a mac issue...).
Using a volume you should be able to add the docker binary like this.

```
-v $(which docker):/usr/bin/docker
```

## Copyright and License
MIT License, see [LICENSE](License.txt) for details.
Copyright (c) 2017 Julien Dubreuil

---

> GitHub [@JulienD](https://github.com/JulienD) &nbsp;&middot;&nbsp;
> [Blog](http://juliendubreuil.fr) &nbsp;&middot;&nbsp;
> Twitter [@juliendubreuil](https://twitter.com/juliendubreuil)

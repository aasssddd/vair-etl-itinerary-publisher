# Dockerfile
FROM centos:centos6
RUN yum install -y epel-release
RUN yum install -y nodejs npm
RUN npm install -g coffee-script
RUN mv /etc/localtime /etc/localtime.bak
RUN cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime
COPY . itineraryPublisher
WORKDIR itineraryPublisher
ENTRYPOINT ["/bin/sh", "-c", "coffee index.coffee $START $END"]
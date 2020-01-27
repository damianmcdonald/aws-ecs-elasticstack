FROM openjdk:8-jdk-alpine
MAINTAINER Damian McDonald <damian.mcdonald1979@gmail.com>

# copy assets
COPY target/servicemock-1.0.4-RELEASE.jar /app/servicemock-1.0.4-RELEASE.jar

# change to ROOT user and make log directory
USER root
RUN mkdir -p /var/log/softwarepackage
RUN chmod -R 777 /var/log/softwarepackage

# define the entrypoint to the app
ENTRYPOINT ["java","-jar","/app/servicemock-1.0.4-RELEASE.jar"]

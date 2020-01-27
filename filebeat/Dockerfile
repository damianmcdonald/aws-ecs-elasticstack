FROM docker.elastic.co/beats/filebeat:6.8.4
MAINTAINER Damian McDonald <damian.mcdonald1979@gmail.com>

# Copy assets
COPY --chown=root:filebeat build/filebeat.yml /usr/share/filebeat/
COPY --chown=root:filebeat build/docker-entrypoint /usr/local/bin/docker-entrypoint

# change to ROOT user and run commands
USER root
RUN mkdir -p /var/log/softwarepackage && \
      chmod 777 /var/log/softwarepackage && \
      chmod go-w /usr/share/filebeat/filebeat.yml
USER filebeat

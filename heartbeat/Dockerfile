FROM docker.elastic.co/beats/heartbeat:6.8.4
MAINTAINER Damian McDonald <damian.mcdonald1979@gmail.com>

# Copy assets
COPY --chown=root:heartbeat build/heartbeat.yml /usr/share/heartbeat/
COPY --chown=root:heartbeat build/http-monitors.yml /usr/share/heartbeat/
COPY --chown=root:heartbeat build/docker-entrypoint /usr/local/bin/docker-entrypoint

# change to ROOT user and run commands
USER root
RUN chmod 640 /usr/share/heartbeat/heartbeat.yml
USER heartbeat
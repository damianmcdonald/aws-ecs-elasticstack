FROM docker.elastic.co/beats/metricbeat:6.8.4
MAINTAINER Damian McDonald <damian.mcdonald1979@gmail.com>

# Copy assets
COPY --chown=root:metricbeat build/metricbeat.yml /usr/share/metricbeat/
COPY --chown=root:metricbeat build/docker-entrypoint /usr/local/bin/docker-entrypoint

# change to ROOT user and run commands
USER root
RUN chmod 640 /usr/share/metricbeat/metricbeat.yml
USER metricbeat

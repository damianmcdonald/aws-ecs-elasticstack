FROM docker.elastic.co/logstash/logstash:6.8.4
MAINTAINER Damian McDonald <damian.mcdonald1979@gmail.com>

# Copy assets
COPY --chown=logstash:root build/conf/ /usr/share/logstash/config/
COPY --chown=logstash:root build/pipeline/logstash.conf /usr/share/logstash/pipeline/

# change to ROOT user and run commands
USER root
RUN chmod 644 /usr/share/logstash/pipeline/logstash.conf && \
      chmod 644 /usr/share/logstash/config/log4j2.properties && \
      chmod 644 /usr/share/logstash/config/logstash.yml && \
      chmod 644 /usr/share/logstash/config/pipelines.yml && \
      chmod 664 /usr/share/logstash/config/jvm.options && \
      chmod 664 /usr/share/logstash/config/logstash-sample.conf && \
      chmod 664 /usr/share/logstash/config/startup.options
USER logstash

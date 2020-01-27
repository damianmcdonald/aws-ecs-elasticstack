FROM bitsensor/elastalert:3.0.0-beta.1
MAINTAINER Damian McDonald <damian.mcdonald1979@gmail.com>

# copy assets
COPY --chown=node:node build/email-credentials.yml /opt/elastalert/secret/email-credentials.yml
COPY --chown=node:node build/config.yaml /opt/elastalert/config.yaml
COPY --chown=node:node build/config.json /opt/elastalert-server/config/config.json
COPY --chown=node:node build/rules/ /opt/elastalert/rules/

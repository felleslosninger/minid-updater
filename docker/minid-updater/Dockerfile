FROM eid-jenkins02.dmz.local:8081/eid-hiera-config:latest AS hiera-config
FROM eid-jenkins02.dmz.local:8081/eid-puppet-modules:latest AS eid-puppet-modules

FROM eid-jenkins02.dmz.local:8081/eid-base:latest as config

ENV FACTER_platform=ondemand
ENV FACTER_hostname=minid-updater
ENV FACTER_fqdn=${FACTER_hostname}
RUN mkdir /etc/puppetlabs/code/environments/ondemand
RUN /opt/puppetlabs/puppet/bin/puppet config set environment ondemand --section user
COPY --from=eid-puppet-modules /puppet_modules /puppet/modules

COPY --from=hiera-config /hiera /puppet/hiera
COPY /puppet_modules/ /puppet/modules/
COPY /puppet_hiera/ /puppet/hiera/

RUN /puppet/puppet-apply

FROM eid-jenkins02.dmz.local:8081/spring-boot-base:latest



ARG APPLICATION=minid-updater
ARG CONTEXT=minid-updater

COPY --from=config /etc/filebeat/ /etc/filebeat/
COPY --from=config /etc/opt/${APPLICATION}/ /etc/opt/${APPLICATION}/


COPY /jar/${APPLICATION}.jar /usr/local/webapps/application.jar
COPY --from=config /opt/${APPLICATION}/${APPLICATION}.conf /usr/local/webapps/application.conf

HEALTHCHECK --interval=10s --start-period=10s --retries=15 \
    CMD { curl -f --max-time 10 http://localhost:8080/health; } || exit 1

ENTRYPOINT ["sh", "/entrypoint.sh"]




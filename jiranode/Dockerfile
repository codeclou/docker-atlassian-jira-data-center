FROM codeclou/docker-oracle-jdk:8u121

ENV JIRA_VERSION 7.3.3

COPY docker-entrypoint.sh /work-private/docker-entrypoint.sh
RUN chmod u+rx,g+rx,o+rx,a-w /work-private/docker-entrypoint.sh && \
    addgroup -g 10777 worker && \
    adduser -h /work -H -D -G worker -u 10777 worker && \
    mkdir -p /work && \
    mkdir -p /work-private && \
    mkdir /jira && mkdir /jira-home && mkdir /jira-shared-home && \
    chown -R worker:worker /work/ && \
    chown -R worker:worker /work-private/ && \
    apk add --no-cache \
            bash \
            curl \
            tar \
            python \
            py-pip && \
            pip install shinto-cli && \
    curl -jkSL -o /opt/jira.tar.gz \
         https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz  && \
    tar zxf /opt/jira.tar.gz -C /jira && \
    rm /opt/jira.tar.gz && \
    chown -R worker:worker /jira && \
    chown -R worker:worker /jira-home/ && \
    chown -R worker:worker /jira-shared-home

#
# CONF
#
COPY dbconfig.xml /jira-home/dbconfig.xml
COPY cluster.properties.jinja2 /work-private/cluster.properties.jinja2

#
# WORKDIR
#
WORKDIR /work
# JIRA HTTP Port
EXPOSE 8080
# JIRA Cluster Sync Port
EXPOSE 40001

#
# RUN
#
USER worker
ENV NODE_NUMBER 1
ENV JIRA_HOME /jira-home
VOLUME ["/work"]
VOLUME ["/jira-shared-home"]
ENTRYPOINT ["/work-private/docker-entrypoint.sh"]
CMD ["/jira/atlassian-jira-software-7.3.3-standalone/bin/catalina.sh", "run"]
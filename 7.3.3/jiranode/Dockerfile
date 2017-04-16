FROM codeclou/docker-atlassian-base-images:jira-software-7.3.3

#
# DOCKER ENTRYPOINT
#
COPY docker-entrypoint.sh /work-private/docker-entrypoint.sh
RUN chmod u+rx,g+rx,o+rx,a-w /work-private/docker-entrypoint.sh

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
# JIRA Cluster EHCache Multicast Port - see: https://forums.rancher.com/t/solved-problems-multicast-ehcache/1507/7
EXPOSE 4446

#
# RUN
#
USER worker
# CONFIG VARS (jinja2)
ENV NODE_NUMBER 1
# INTERNAL CONFIG
ENV JIRA_HOME /jira-home
VOLUME ["/work"]
VOLUME ["/jira-shared-home"]
ENTRYPOINT ["/work-private/docker-entrypoint.sh"]
CMD ["/jira/atlassian-jira-software-latest-standalone/bin/catalina.sh", "run"]

# docker-atlassian-jira-data-center

Start an [Atlassian JIRA® Software Data Center](https://de.atlassian.com/enterprise/data-center) with Docker for local testing during plugin development.
It starts a PostgreSQL Database, several JIRA® cluster nodes and Apache2 HTTPD as sticky session loadbalancer. The shared jira-home is handled via a shared Docker volume. This is not meant to be used in production! The cluster is designed to not be persistent, meaning, once you shut it down, all data is lost. See it as the Data-Center version of [`atlas-run-standalone`](https://developer.atlassian.com/docs/developer-tools/working-with-the-sdk/command-reference/atlas-run-standalone).

[![](https://codeclou.github.io/docker-atlassian-jira-data-center/img/manage-jira-cluster-logo.svg)](https://github.com/codeclou/docker-atlassian-jira-data-center)


Please choose the JIRA Software version you want to run:

|JIRA Software Version | Loadbalancer URL | PostgreSQL Version | Oracle Java Version |
|-------------------|--------------------|-----------------|-----------------------|
| **⇨ [7.3.3](https://github.com/codeclou/docker-atlassian-jira-data-center/tree/master/7.3.3)** | http://jira-cluster-733-lb:60733/ | [9.4](https://hub.docker.com/_/postgres/) | [8u131](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-7.3.3/Dockerfile) |
| **⇨ [7.4.0](https://github.com/codeclou/docker-atlassian-jira-data-center/tree/master/7.4.0)** | http://jira-cluster-740-lb:60740/ | [9.4](https://hub.docker.com/_/postgres/) | [8u131](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-7.4.0/Dockerfile) |

**Please Note:**
 * I do not provide support. If you have questions on how to run JIRA Software and/or JIRA Data Center, please ask in the
[Atlassian Community](https://community.atlassian.com/).

-----

&nbsp;

### Trademarks and Third Party Licenses

 * **Atlassian JIRA® Sofware**
   * Atlassian®, JIRA®, JIRA® Software are registered [trademarks of Atlassian Pty Ltd](https://de.atlassian.com/legal/trademark).
   * Please check yourself for corresponding Licenses and Terms of Use at [atlassian.com](https://atlassian.com).
 * **Oracle Java JDK 8**
   * Oracle and Java are registered [trademarks of Oracle](https://www.oracle.com/legal/trademarks.html) and/or its affiliates. Other names may be trademarks of their respective owners.
   * Please check yourself for corresponding Licenses and Terms of Use at [www.oracle.com](https://www.oracle.com/).
 * **Docker**
   * Docker and the Docker logo are trademarks or registered [trademarks of Docker](https://www.docker.com/trademark-guidelines), Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein.
   * Please check yourself for corresponding Licenses and Terms of Use at [www.docker.com](https://www.docker.com/).
 * **PostgreSQL**
   * PostgreSQL is a [registered trademark of the PostgreSQL Community Association of Canada](https://wiki.postgresql.org/wiki/Trademark_Policy).
   * Please check yourself for corresponding Licenses and Terms of Use at [www.postgresql.org](https://www.postgresql.org/).
 * **Ubuntu**
   * Ubuntu and Canonical are registered [trademarks of Canonical Ltd.](https://www.ubuntu.com/legal/short-terms)
 * **Apple**
   * macOS®, Mac and OS X are [trademarks of Apple Inc.](http://www.apple.com/legal/intellectual-property/trademark/appletmlist.html), registered in the U.S. and other countries.

-----

&nbsp;

### License

[MIT](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/LICENSE) © [Bernhard Grünewaldt](https://github.com/clouless)

# Docker Atlassian Jira Data Center

> Start an [Atlassian Jira Software Data Center](https://de.atlassian.com/enterprise/data-center) with Docker for local testing during plugin development.

[![](https://codeclou.github.io/docker-atlassian-jira-data-center/img/github-product-logo-docker-atlassian-jira.png)](https://github.com/codeclou/docker-atlassian-jira-data-center)

It starts a PostgreSQL Database, several Jira cluster nodes and Apache2 HTTPD as sticky session loadbalancer. The shared jira-home is handled via a shared Docker volume. This is not meant to be used in production! The cluster is designed to not be persistent, meaning, once you shut it down, all data is lost. See it as the Data-Center version of [`atlas-run-standalone`](https://developer.atlassian.com/docs/developer-tools/working-with-the-sdk/command-reference/atlas-run-standalone).

Please choose the Jira Software version you want to run:

| Jira Software Version                                                                                   | Loadbalancer URL                 |
| ------------------------------------------------------------------------------------------------------- | -------------------------------- |
| **⇨ [8.8.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/versions/8.8.0)** | http://jira-cluster-880-lb:1880/ |
| **⇨ [8.7.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/versions/8.7.0)** | http://jira-cluster-870-lb:1870/ |
| **⇨ [8.6.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/versions/8.6.0)** | http://jira-cluster-860-lb:1860/ |
| **⇨ [8.5.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/versions/8.5.0)** | http://jira-cluster-850-lb:1850/ |
| **⇨ [8.4.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/versions/8.4.0)** | http://jira-cluster-840-lb:1840/ |

**Please Note:**

- :warning: **Since version 8.4.0 we use the official Atlassian Docker images and docker compose.**
  - Older versions can be found in [codeclou-archive/docker-atlassian-jira-data-center](https://github.com/codeclou-archive/docker-atlassian-jira-data-center)
- We do not provide support. If you have questions on how to run Jira Software and/or Jira Data Center, please ask in the
  [Atlassian Community](https://community.atlassian.com/).

---

&nbsp;

### Trademarks and Third Party Licenses

- **Atlassian Jira Sofware**
  - Atlassian, Jira, Jira Software are registered [trademarks of Atlassian Pty Ltd](https://de.atlassian.com/legal/trademark).
  - Please check yourself for corresponding Licenses and Terms of Use at [atlassian.com](https://atlassian.com).
- **Oracle Java JDK**
  - Oracle, OpenJDK and Java are registered [trademarks of Oracle](https://www.oracle.com/legal/trademarks.html) and/or its affiliates. Other names may be trademarks of their respective owners.
  - Please check yourself for corresponding Licenses and Terms of Use at [www.oracle.com](https://www.oracle.com/).
- **Docker**
  - Docker and the Docker logo are trademarks or registered [trademarks of Docker](https://www.docker.com/trademark-guidelines), Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein.
  - Please check yourself for corresponding Licenses and Terms of Use at [www.docker.com](https://www.docker.com/).
- **PostgreSQL**
  - PostgreSQL is a [registered trademark of the PostgreSQL Community Association of Canada](https://wiki.postgresql.org/wiki/Trademark_Policy).
  - Please check yourself for corresponding Licenses and Terms of Use at [www.postgresql.org](https://www.postgresql.org/).
- **Ubuntu**
  - Ubuntu and Canonical are registered [trademarks of Canonical Ltd.](https://www.ubuntu.com/legal/short-terms)
- **Apple**
  - macOS®, Mac and OS X are [trademarks of Apple Inc.](http://www.apple.com/legal/intellectual-property/trademark/appletmlist.html), registered in the U.S. and other countries.

---

&nbsp;

### License

[MIT](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/LICENSE) © [Bernhard Grünewaldt](https://github.com/clouless)

# Docker Atlassian Jira Data Center

Start an [Atlassian Jira Software Data Center](https://de.atlassian.com/enterprise/data-center) with Docker for local testing during plugin development.

[![](https://codeclou.github.io/docker-atlassian-jira-data-center/img/github-product-logo-docker-atlassian-jira.png)](https://github.com/codeclou/docker-atlassian-jira-data-center)

It starts a PostgreSQL Database, several Jira cluster nodes and Apache2 HTTPD as sticky session loadbalancer. The shared jira-home is handled via a shared Docker volume. This is not meant to be used in production! The cluster is designed to not be persistent, meaning, once you shut it down, all data is lost. See it as the Data-Center version of [`atlas-run-standalone`](https://developer.atlassian.com/docs/developer-tools/working-with-the-sdk/command-reference/atlas-run-standalone).

Please choose the JIRA Software version you want to run:

<!-- | **⇨ [8.3.0-m0003](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/8.3.0-m0003)** | http://jira-cluster-820-lb:1830/ | [9.4](https://hub.docker.com/_/postgres/) | [AdoptOpenJDK 11](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-8.3.0-m0003/Dockerfile) | -->

|Jira Software Version | Loadbalancer URL | PostgreSQL Version | Oracle Java Version |
|-------------------|--------------------|-----------------|-----------------------|
| **⇨ [8.2.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/8.2.0)** | http://jira-cluster-820-lb:1820/ | [9.4](https://hub.docker.com/_/postgres/) | [AdoptOpenJDK 11](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-8.2.0/Dockerfile) |
| **⇨ [8.1.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/8.1.0)** | http://jira-cluster-810-lb:1810/ | [9.4](https://hub.docker.com/_/postgres/) | [AdoptOpenJDK 8u202](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-8.1.0/Dockerfile) |
| **⇨ [8.0.2](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/8.0.2)** | http://jira-cluster-802-lb:1802/ | [9.4](https://hub.docker.com/_/postgres/) | [OpenJDK 8u181](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-8.0.2/Dockerfile) |
| **⇨ [8.0.1](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/8.0.1)** | http://jira-cluster-801-lb:1801/ | [9.4](https://hub.docker.com/_/postgres/) | [OpenJDK 8u181](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-8.0.1/Dockerfile) |
| **⇨ [8.0.0-m0030-beta](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/8.0.0-m0030-beta)** | http://jira-cluster-800-lb:1800/ | [9.4](https://hub.docker.com/_/postgres/) | [OpenJDK 8u192](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-8.0.0-m0030-beta/Dockerfile) |
| **⇨ [7.13.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/7.13.0)** | http://jira-cluster-7130-lb:17130/ | [9.4](https://hub.docker.com/_/postgres/) | [OpenJDK 8u181](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-7.13.0/Dockerfile) |
| **⇨ [7.12.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/7.12.0)** | http://jira-cluster-7120-lb:17120/ | [9.4](https://hub.docker.com/_/postgres/) | [Oracle JDK 8u152](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-7.12.0/Dockerfile) |
| **⇨ [7.11.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/7.11.0)** | http://jira-cluster-7110-lb:17110/ | [9.4](https://hub.docker.com/_/postgres/) | [Oracle JDK 8u152](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-7.11.0/Dockerfile) |
| **⇨ [7.10.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/7.10.0)** | http://jira-cluster-7100-lb:17100/ | [9.4](https://hub.docker.com/_/postgres/) | [Oracle JDK 8u152](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-7.10.0/Dockerfile) |
| **⇨ [7.9.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/7.9.0)** | http://jira-cluster-790-lb:60790/ | [9.4](https://hub.docker.com/_/postgres/) | [Oracle JDK 8u152](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-7.9.0/Dockerfile) |
| **⇨ [7.8.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/7.8.0)** | http://jira-cluster-780-lb:60780/ | [9.4](https://hub.docker.com/_/postgres/) | [Oracle JDK 8u152](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-7.8.0/Dockerfile) |
| **⇨ [7.7.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/7.7.0)** | http://jira-cluster-770-lb:60770/ | [9.4](https://hub.docker.com/_/postgres/) | [Oracle JDK 8u152](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-7.7.0/Dockerfile) |
| **⇨ [7.6.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/7.6.0)** | http://jira-cluster-760-lb:60760/ | [9.4](https://hub.docker.com/_/postgres/) | [Oracle JDK 8u141](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-7.6.0/Dockerfile) |
| **⇨ [7.5.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/7.5.0)** | http://jira-cluster-750-lb:60750/ | [9.4](https://hub.docker.com/_/postgres/) | [Oracle JDK 8u141](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-7.5.0/Dockerfile) |
| **⇨ [7.4.0](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/7.4.0)** | http://jira-cluster-740-lb:60740/ | [9.4](https://hub.docker.com/_/postgres/) | [Oracle JDK 8u131](https://github.com/codeclou/docker-atlassian-base-images/blob/jira-software-7.4.0/Dockerfile) |

**Please Note:**
 * We do not provide support. If you have questions on how to run Jira Software and/or Jira Data Center, please ask in the
[Atlassian Community](https://community.atlassian.com/).

-----

&nbsp;

### Trademarks and Third Party Licenses

 * **Atlassian Jira Sofware**
   * Atlassian, Jira, Jira Software are registered [trademarks of Atlassian Pty Ltd](https://de.atlassian.com/legal/trademark).
   * Please check yourself for corresponding Licenses and Terms of Use at [atlassian.com](https://atlassian.com).
 * **Oracle Java JDK**
   * Oracle, OpenJDK and Java are registered [trademarks of Oracle](https://www.oracle.com/legal/trademarks.html) and/or its affiliates. Other names may be trademarks of their respective owners.
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

# docker-atlassian-jira-data-center

[![](https://codeclou.github.io/doc/badges/generated/docker-image-size-500.svg?v2)](https://hub.docker.com/r/codeclou/docker-atlassian-jira-data-center/tags/) [![](https://codeclou.github.io/doc/badges/generated/docker-from-alpine-3.5.svg)](https://alpinelinux.org/) [![](https://codeclou.github.io/doc/badges/generated/docker-run-as-non-root.svg)](https://docs.docker.com/engine/reference/builder/#/user)

Dockerized [Atlassian JIRA® Data Center](https://de.atlassian.com/enterprise/data-center) for local testing during plugin development.

-----

&nbsp;

### Prerequisites


 * Runs as non-root with fixed UID 10777 and GID 10777. See [howto prepare volume permissions](https://github.com/codeclou/doc/blob/master/docker/README.md).
 * See [howto use SystemD for named Docker-Containers and system startup](https://github.com/codeclou/doc/blob/master/docker/README.md).
 * You need Linux or macOS.
 * Basic unix-tools like `wc`, `awk`, `curl` and `bash` must be installed.
 * Bash 3 or 4 must be installed.
 * Latest Docker version must be installed.

-----

&nbsp;

### Prerequisites

**(1)** Add cluster hostname alias

Add the alias on your Docker-Host machine.

```bash
sudo su
echo "127.0.0.1  jira-cluster-lb" >> /etc/hosts
```
If you like to work with your cluster from your local network, use the servers public IP instead.

&nbsp;

**(2)** Enable Network Forwarding (Multicast). On macOS do:

JIRA® Data Center uses [EHCache Multicast networking features](http://www.ehcache.org/documentation/2.8/replication/rmi-replicated-caching.html). We need to enable IP Forwarding.

On macOS you do this with:

```bash
sudo sysctl -w net.inet.ip.forwarding=1
```

**(3)** Install Cluster Management Script

```bash
cd /usr/local/bin
curl -O https://raw.githubusercontent.com/codeclou/docker-atlassian-jira-data-center/master/manage-cluster.sh
chmod +x /usr/local/bin manage-cluster.sh
```

-----

&nbsp;

### Usage

**(1)** Start a JIRA® Data Center Cluster
 
```bash
manage-cluster.sh --action create --scale 1
```

Important: 
 * We start with one loadbalancer, one JIRA® node and one PostgreSQL Database. After we post configured the first JIRA® node we will add more nodes.
 * Directory `/tmp/jira-shared-home` is used instead of NFS as replacement for the shared-filesystem across all JIRA® nodes. 


**(2)** Browse to JIRA® Software

 * Open a browser to [http://jira-cluster-lb:9980/](http://jira-cluster-lb:9980/)
 * It might take several minutes for the cluster to fully start up.

&nbsp;

**(3) Check Containers**

Check if all containers have started with:

```bash
docker ps --format '{{.ID}}\t{{.Names}}\t\t{{.Ports}}' --filter='name=jira-cluster'
```

Should show something like:

```
101c71ae0c12    jira-cluster-node1     4446/tcp, 8080/tcp, 40001/tcp
62fba1910763    jira-cluster-node2     4446/tcp, 8080/tcp, 40001/tcp
e2e9a6b1b757    jira-cluster-db        5432/tcp
72f92316309f    jira-cluster-lb        0.0.0.0:9980->9980/tcp
```

&nbsp;

**(4) Start Post Configuration**

Once the cluster is fully started up, you need to configure JIRA® Software in the browser.

Go to **[http://jira-cluster-lb:9980/](http://jira-cluster-lb:9980/)** and make sure you enabled cookies (sticky session).

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-01-allow-cookies.png" width="80%"></p>

Use `http://jira-cluster-lb:9980` as Base URL.

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-02-baseurl.png" width="80%"></p>

You can either use a [Atlassian Data Center Timebomb Licenses](https://developer.atlassian.com/market/add-on-licensing-for-developers/timebomb-licenses-for-testing)
or at best get a JIRA® Software Data Center 30 Days Trial License from [my.atlassian.com](https://my.atlassian.com/product).

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-03-license.png" width="80%"></p>

Configure your user.

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-04-username.png" width="80%"></p>

Skip E-Mail Setup and click yourself through to the end of the installation.

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-05-email-later.png" width="80%"></p>

Check if clustering is activated under `System`  → `System Info` and search for `Clustering`

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-06-systeminfo-clustering-on.png" width="80%"></p>

Use the [JIRA® Data Center Health Check Tools](https://confluence.atlassian.com/enterprise/jira-data-center-health-check-tools-644580752.html)
to check the Health of each cluster node. `System`  → `Atlassian Support Tools` → `Health Checks tab`

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-07-health-checks.png" width="80%"></p>






&nbsp;

**(5) Scale Up Cluster - Add JIRA® Nodes**

Now that our first JIRA® Node is fully working we add additional nodes to our existing cluster.

```bash
manage-cluster.sh --action update --scale 3
```

This will **add two additional JIRA® Nodes** and reconfigure the loadbalancer automatically.

Wait again several minutes and now check if all nodes are active and alive under `System`  → `System Info` and search for `Cluster Nodes`

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-09-systeminfo-all-nodes-active.png?v2" width="80%"></p>

If not all nodes you have started are active, try restarting all nodes not showing up.

For example if Instance 3 does not show up, you can restart it like so:

```bash
manage-cluster.sh --action restart-node --id 3
```

&nbsp;

Now your cluster should be up and running.



&nbsp;

**(6) Shutting down the cluster**

```bash
manage-cluster.sh --action destroy
```

This will kill and remove all instances.

-----

&nbsp;

### FAQ

**Why not use Docker Swarm Mode?**

 * Because we need a sticky session loadbalancer, and the whole idea of swarm mode is to have identical 
stateless worker nodes. JIRA® Data Center on the other hand relies on a state for each node.

&nbsp;

**Why PostgreSQL 9.4?**

 * [JIRA Software 7.x supports max PostgreSQL 9.4](https://confluence.atlassian.com/adminjiraserver072/supported-platforms-828787550.html)

-----

&nbsp;

### Compatibility

Tested under the following Operating Systems:

 * Ubuntu 16.04 64 Bit Server
   * Docker version 17.03.0-ce, build 60ccb22
   * GNU bash, version 4.3.46(1)-release (x86_64-pc-linux-gnu)
 * OS X El Capitan
   * Docker version 17.03.0-ce, build 60ccb22
   * GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin15)

:bangbang: Might not run under Windows.

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

-----

&nbsp;

### License

[MIT](./LICENSE) © [Bernhard Grünewaldt](https://github.com/clouless)

# docker-atlassian-jira-data-center

[![](https://codeclou.github.io/doc/badges/generated/docker-image-size-500.svg?v2)](https://hub.docker.com/r/codeclou/docker-atlassian-jira-data-center/tags/)  [![](https://codeclou.github.io/doc/badges/generated/docker-run-as-non-root.svg)](https://docs.docker.com/engine/reference/builder/#/user)

[![](https://codeclou.github.io/docker-atlassian-jira-data-center/img/manage-jira-cluster-logo.svg)](https://github.com/codeclou/docker-atlassian-jira-data-center)

## Version 8.4.0-m0003

Start an [Atlassian Jira Software Data Center](https://de.atlassian.com/enterprise/data-center) version 8.4.0-m0003 with Docker for local testing during plugin development.
It starts a PostgreSQL Database, several Jira Software cluster nodes and Apache2 HTTPD as sticky session loadbalancer. The shared jira-home is handled via a shared Docker volume.

&nbsp;

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/7.3.3/img/demo.gif?v2" width="80%"/></p>


-----

&nbsp;

### Manage Cluster Script

To start, scale, stop and destroy the cluster, the [`manage-jira-cluster-8.4.0-m0003.sh`](https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/8.4.0-m0003/manage-jira-cluster-8.4.0-m0003.sh) script is provided.
It basically works in the following way:


  * It creates a docker bridge network called `jira-cluster-840`.
  * It creates a shared volume called `jira-shared-home-840`.
  * It creates a docker container called `jira-cluster-840-lb` as the loadbalancer.
    * Binds Port 50611/tcp to the host.
  * It creates a docker container called `jira-cluster-840-db` as the database.
    * Port 5432/tcp are only exposed inside the `jira-cluster-840` network.
  * It creates multiple docker containers called `jira-cluster-840-node{n}` as JIRA Software instances.
    * With `n ∈ {1,2,3,...,100}`.
    * An instance runs [JIRA Software](https://confluence.atlassian.com/jirasoftwareserver073/installing-jira-software-861254170.html) on Port 8080/tcp.
    * Port 8080/tcp and the multicast Ports 40001,4446/tcp are only exposed inside the `jira-cluster-840` network.

The script is meant to follow the convention over configuration paradigma, therefore there is not much to be configured, except one thing:

  * It relies on the hostname `jira-cluster-840-lb` pointing to the interface which binds 1840/tcp.


-----

&nbsp;

### Prerequisites

 * All Docker containers run internally as non-root with fixed UID 10777 and GID 10777.
 * You need Linux or macOS®.
 * Basic unix-tools like `wc`, `awk`, `curl`, `tr`, `head` and `bash` must be installed.
 * Bash 3 or 4 must be installed.
 * Latest Docker version must be installed.

-----

&nbsp;

### Initial Configuration

**(1) Add cluster hostname alias**

Add the alias on your Docker-Host machine.

```bash
sudo su
echo "127.0.0.1  jira-cluster-840-lb" >> /etc/hosts
```
If you like to work with your cluster from your local network, use the servers public IP instead.

&nbsp;

**(2) Enable Network Forwarding (Multicast)**

Jira Data Center uses [EHCache Multicast networking features](http://www.ehcache.org/documentation/2.8/replication/rmi-replicated-caching.html). We need to enable IP Forwarding.

On macOS® you do this with:

```bash
sudo sysctl -w net.inet.ip.forwarding=1
```

&nbsp;

**(3) Install Cluster Management Script**

On macOS® you do this with:

```bash
#
# DOWNLOAD MANAGEMENT SCRIPT
#
curl -so /usr/local/bin/manage-jira-cluster-8.4.0-m0003.sh \
"https://raw.githubusercontent.com/codeclou/docker-atlassian-jira-\
data-center/master/8.4.0-m0003/manage-jira-cluster-8.4.0-m0003.sh"

#
# MAKE EXECUTABLE
#
chmod +x /usr/local/bin/manage-jira-cluster-8.4.0-m0003.sh
```



-----

&nbsp;

### Usage

**(1) Start a Jira Data Center 8.4.0-m0003 Cluster**

```bash
manage-jira-cluster-8.4.0-m0003.sh --action create --scale 1
```

Important:
 * We start with one loadbalancer, one Jira node and one PostgreSQL Database.
 * Since Jira 8.3 we ship it with a pre-configured database, jira-home and jira-shared-home.
 * After we post configured the first Jira node we will add more nodes.

&nbsp;

**(2) Browse to Jira Software**

 * Open a browser to [http://jira-cluster-840-lb:1840/](http://jira-cluster-840-lb:1840/)
 * It might take several minutes for the cluster to fully start up.

&nbsp;

**(3) Check Containers**

Check if all containers have started with:

```bash
manage-jira-cluster-8.4.0-m0003.sh --action info
```

Should show something like:

```
101c71ae0c12    jira-cluster-840-node1     4446/tcp, 8080/tcp, 40001/tcp
e2e9a6b1b757    jira-cluster-840-db        5432/tcp
72f92316309f    jira-cluster-840-lb        0.0.0.0:1840->1840/tcp
```

You can check the logs of each container by calling e.g.:

```bash
docker logs jira-cluster-840-node1
```


&nbsp;

**(4) Start Post Configuration**

Once the cluster is fully started up, you need to configure Jira Software in the browser.

Go to **[http://jira-cluster-840-lb:1840/](http://jira-cluster-840-lb:1840/)** and make sure you enabled cookies (sticky session).

Wait for Jira to start up. Simply reload this page after a few minutes.

<p align="center"><img width="80%" alt="jira-startup-01" src="https://user-images.githubusercontent.com/12599965/64061646-25de1380-cbde-11e9-85e3-d8994d10b0b5.png"></p>


Set the baseUrl to `http://jira-cluster-840-lb:1840` and continue.

<p align="center"><img width="80%" src="https://user-images.githubusercontent.com/12599965/64064654-99931700-cc04-11e9-8632-6431a72caa5f.png"/></p>

Use a Data Center license. Either an Evaluation License or a [Timebomb License](https://developer.atlassian.com/platform/marketplace/timebomb-licenses-for-testing-server-apps/).

<p align="center"><img width="80%" src="https://user-images.githubusercontent.com/12599965/64064667-cba47900-cc04-11e9-8f2b-c7d7fbe7cddb.png"/></p>


Setup your admin account. Usually username `admin` and password `admin`.

<p align="center"><img width="80%" src="https://user-images.githubusercontent.com/12599965/64064718-6b620700-cc05-11e9-8133-48152d89f284.png"/></p>

Finish setup.

<p align="center"><img width="80%" src="https://user-images.githubusercontent.com/12599965/64064726-9e0bff80-cc05-11e9-838a-e13abd800e0c.png"/></p>

&nbsp;


Use the [Jira Data Center Health Check Tools](https://confluence.atlassian.com/enterprise/jira-data-center-health-check-tools-644580752.html)
to check the Health of each cluster node. `System`  → `Troubleshooting and support Tools` → `Instance Health` tab

<p align="center"><img src="https://user-images.githubusercontent.com/12599965/64064796-98fb8000-cc06-11e9-85c3-3e28217e4c79.png" width="80%"/></p>






&nbsp;

**(5) Scale Up Cluster - Add Jira Nodes**

Now that our first Jira Node is fully working we add additional nodes to our existing cluster.

```bash
manage-jira-cluster-8.4.0-m0003.sh --action update --scale 3
```

This will **add two additional Jira Nodes** and reconfigure the loadbalancer automatically.

Wait again several minutes and now check if all nodes are active and alive under `System`  → `System Info` and search for `Cluster Nodes`

<p align="center"><img src="https://user-images.githubusercontent.com/12599965/64064774-6487c400-cc06-11e9-8b29-c005f8a7ac0d.png" width="80%"/></p>

If not all nodes you have started are active, try restarting all nodes not showing up.

For example if Instance 3 does not show up, you can restart it like so:

```bash
manage-jira-cluster-8.4.0-m0003.sh --action restart-node --id 3
```

&nbsp;

Now your cluster should be up and running.



&nbsp;

**(6) Shutting down the cluster**

```bash
manage-jira-cluster-8.4.0-m0003.sh --action destroy
```

This will kill and remove all instances.

-----

&nbsp;

### FAQ

**Why not use Docker Swarm Mode?**

 * Because we need a sticky session loadbalancer, and the whole idea of swarm mode is to have identical
stateless worker nodes. Jira Data Center on the other hand relies on a state for each node.

&nbsp;

**Why PostgreSQL 9.4?**

 * [JIRA Software 7.x supports max PostgreSQL 9.4](https://confluence.atlassian.com/adminjiraserver072/supported-platforms-828787550.html)



&nbsp;

**Running with ufw and iptables on Ubuntu**

If you run docker on ubuntu behind UFW and started docker with `--iptables=false` then you
need to enable Postrouting in `/etc/ufw/before.rules` for the network.

Use `docker network list` to get Network-ID which is then `br-NETWORK-ID` under ifconfig, where you get the network range in my case 172.18.0.0.

```
*nat
:POSTROUTING ACCEPT [0:0]
#...
# DOCKER jira-cluster-840 network
-A POSTROUTING ! -o br-8a831390552b -s 172.18.0.0/16 -j MASQUERADE
#...
COMMIT
```

&nbsp;


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

Not tested and not compatible under the following Operating Systems:

  * Microsoft Windows

-----

&nbsp;

### Trademarks and Third Party Licenses

 * **Atlassian Jira Sofware**
   * Atlassian®, Jira, Jira Software are registered [trademarks of Atlassian Pty Ltd](https://de.atlassian.com/legal/trademark).
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

[MIT](./LICENSE) © [Bernhard Grünewaldt](https://github.com/clouless)

# docker-atlassian-jira-data-center

> Start an [Atlassian Jira Software Data Center](https://de.atlassian.com/enterprise/data-center) with Docker for local testing during plugin development.

[![](https://codeclou.github.io/docker-atlassian-jira-data-center/img/github-product-logo-docker-atlassian-jira.png)](https://github.com/codeclou/docker-atlassian-jira-data-center)

## Version 8.8.0

It starts a PostgreSQL Database, two Jira Software cluster nodes and Apache2 HTTPD as sticky session loadbalancer. The shared jira-home is handled via a shared Docker volume mounts.

-----

&nbsp;

### Prerequisites

 * All Docker containers run internally as non-root with fixed UID 10777 and GID 10777.
   * The Atlassian Docker container use UID and GID 2001.
 * You need Linux or macOS.
 * Basic unix-tools like `wc`, `awk`, `curl`, `tr`, `head` and `bash` must be installed.
 * Bash 3 or 4 must be installed.
 * Latest Docker version must be installed.
 * docker-compose must be installed.

-----

&nbsp;

### Initial Configuration

**(1) Add cluster hostname alias**

Add the alias on your Docker-Host machine.

```bash
sudo su
echo "127.0.0.1  jira-cluster-880-lb" >> /etc/hosts
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

**(3) Create work directories**

```
sudo mkdir -p /opt/jira-cluster/
NORMALUSER=$(whoami)
sudo chown $NORMALUSER /opt/jira-cluster/
```

**(4) On macOS add /opt/jira-cluster/ to Docker Settings**

Under Docker Settings add `/opt/jira-cluster/` to *File Sharing* folders 
and restart docker.

-----

&nbsp;

### Usage

**(1) Start a Jira Data Center 8.8.0 Cluster**

```bash
rm -rf /opt/jira-cluster/8.8.0 | true
mkdir -p /opt/jira-cluster/8.8.0
mkdir -p /opt/jira-cluster/8.8.0/jira-home-shared
mkdir -p /opt/jira-cluster/8.8.0/jira-home-node1
mkdir -p /opt/jira-cluster/8.8.0/jira-home-node2
# If on linux fix permissions for volume mounts
# sudo chown 2001:2001 /opt/jira-cluster/8.8.0/jira-*
```

Now download the `docker-compose-one-node.yml` file which defines the nodes. We use the official [Atlassian Docker Jira Software images](https://hub.docker.com/r/atlassian/jira-software).

```bash
cd /opt/jira-cluster/8.8.0
curl -so docker-compose-one-node.yml \
"https://raw.githubusercontent.com/codeclou/docker-atlassian-jira-\
data-center/master/versions/8.8.0/docker-compose-one-node.yml"

docker-compose -f docker-compose-one-node.yml up --detach 

# if some longer HTTP 503, try restarting Loadbalancer
docker-compose -f docker-compose-one-node.yml restart jira-cluster-880-lb
```

This will start one Jira Cluster node, a loadbalancer and a PostgreSQL database.

&nbsp;

**(2) Browse to Jira Software**

 * Open a browser to [http://jira-cluster-880-lb:1880/](http://jira-cluster-880-lb:1880/)
 * It might take several minutes for the cluster to fully start up.

&nbsp;

**(3) Check Containers**

Check if all containers have started with:

```bash
docker ps
```

Should show something like:

```
CONTAINER ID        IMAGE                           COMMAND                  PORTS                    NAMES
15ed1263c551        loadbalancer:v2                 "/work-private/docke…"   0.0.0.0:1880->1880/tcp   jira-cluster-880-lb
2994d0d680ad        atlassian/jira-software:8.8.0   "/tini -- /entrypoin…"   8080/tcp                 jira-cluster-880-node1
572fcaf9f669        postgres:9.6                    "docker-entrypoint.s…"   5432/tcp                 jira-cluster-880-db
```

You can check the logs of all containers by calling e.g.:

```bash
docker-compose -f docker-compose-one-node.yml logs
```


&nbsp;

**(4) Start Post Configuration**

Once the cluster is fully started up, you need to configure Jira Software in the browser.

Go to **[http://jira-cluster-880-lb:1880/](http://jira-cluster-880-lb:1880/)** and make sure you enabled cookies (sticky session).

Wait for Jira to start up. Simply reload this page after a few minutes.

<p align="center"><img width="80%" alt="jira-startup-01" src="https://user-images.githubusercontent.com/12599965/64061646-25de1380-cbde-11e9-85e3-d8994d10b0b5.png"></p>


Set the baseUrl to `http://jira-cluster-880-lb:1880` and continue.

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



&nbsp;

**(5) Scale Up Cluster - Add Jira Nodes**

To add a second node do:

```
curl -so docker-compose-two-nodes.yml \
"https://raw.githubusercontent.com/codeclou/docker-atlassian-jira-\
data-center/master/versions/8.8.0/docker-compose-two-nodes.yml"

docker-compose -f docker-compose-two-nodes.yml up -d
docker-compose -f docker-compose-two-nodes.yml restart jira-cluster-880-lb
```

Now you should see both Cluster Nodes as active under `System` → `Clustering`

<p align="center"><img src="https://user-images.githubusercontent.com/12599965/71469542-caa5e180-27c9-11ea-9198-e7c1b1a72eaa.png" width="80%"/></p>



Now scale the cluster up to three nodes.

```bash
cd /opt/jira-cluster/8.8.0
mkdir -p /opt/jira-cluster/8.8.0/jira-home-node3
mkdir -p /opt/jira-cluster/8.8.0/jira-home-node4
# If on linux fix permissions for volume mounts
# sudo chown 2001:2001 /opt/jira-cluster/8.8.0/jira-*
```

```
curl -so docker-compose-three-nodes.yml \
"https://raw.githubusercontent.com/codeclou/docker-atlassian-jira-\
data-center/master/versions/8.8.0/docker-compose-three-nodes.yml"

docker-compose -f docker-compose-three-nodes.yml up -d
docker-compose -f docker-compose-three-nodes.yml restart jira-cluster-880-lb
```

Or even scale up to four nodes.

```
curl -so docker-compose-four-nodes.yml \
"https://raw.githubusercontent.com/codeclou/docker-atlassian-jira-\
data-center/master/versions/8.8.0/docker-compose-four-nodes.yml"

docker-compose -f docker-compose-four-nodes.yml up -d
docker-compose -f docker-compose-three-nodes.yml restart jira-cluster-880-lb
```

To check call this multiple times, and it should output the different node ids after some time

```
curl -I -s http://jira-cluster-880-lb:1880 | grep X-ANODEID
```

&nbsp;

**(6) Shutting down the cluster**

```bash
cd /opt/jira-cluster/8.8.0
docker-compose -f docker-compose-two-nodes.yml down
```

This will kill and remove all instances.

-----

&nbsp;

**Running with ufw and iptables on Ubuntu**

If you run docker on ubuntu behind UFW and started docker with `--iptables=false` then you
need to enable Postrouting in `/etc/ufw/before.rules` for the network.

Use `docker network list` to get Network-ID which is then `br-NETWORK-ID` under ifconfig, where you get the network range in my case 172.18.0.0.

```
*nat
:POSTROUTING ACCEPT [0:0]
#...
# DOCKER jira-cluster-880 network
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
 * **Oracle Java**
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

[MIT](./LICENSE) © [Bernhard Grünewaldt](https://github.com/clouless)

# docker-atlassian-jira-data-center

Dockerized [Atlassian JIRA® Data Center](https://de.atlassian.com/enterprise/data-center) for local testing during plugin development.

-----

&nbsp;

### Prerequisites


 * Runs as non-root with fixed UID 10777 and GID 10777. See [howto prepare volume permissions](https://github.com/codeclou/doc/blob/master/docker/README.md).
 * See [howto use SystemD for named Docker-Containers and system startup](https://github.com/codeclou/doc/blob/master/docker/README.md).

-----

&nbsp;

### Quickstart

**(1)** Start a dockerized JIRA Data Center with one loadbalancer, two JIRA nodes and a PostgreSQL Database.

```bash
git clone https://github.com/codeclou/docker-atlassian-jira-data-center.git
cd docker-atlassian-jira-data-center
bash start-cluster.sh
```

**(2)** Add cluster hostname alias

```bash
sudo su
echo "127.0.0.1  jira-cluster-lb" >> /etc/hosts
```
**(3)** Enable Network Forwarding (Multicast)

macOS: `sudo sysctl -w net.inet.ip.forwarding=1`
 
**(4)** Browse to JIRA Software

 * [http://jira-cluster-lb:9980/](http://jira-cluster-lb:9980/)
 * It might take several minutes for the cluster to fully start up.

-----

&nbsp;

### Usage with Docker in Detail

Everything explained here is automatically done by the `start-cluster.sh`.

&nbsp;

**(1) Cluster Hostname**

Put the cluster-hostname to your `/etc/hosts` file

```bash
sudo su
echo "127.0.0.1  jira-cluster-lb" >> /etc/hosts
```

&nbsp;

**(2) Network**

Create a network for your cluster.

```bash
docker network create jira-cluster
```

&nbsp;

**(3) IP Forwarding for Multicast**

JIRA Data Center uses [EHCache Multicast networking features](http://www.ehcache.org/documentation/2.8/replication/rmi-replicated-caching.html). We need to enable IP Forwarding.

On macOS you do this with:

```bash
sudo sysctl -w net.inet.ip.forwarding=1
```

&nbsp;

**(4) PostgreSQL Database**

Start the Database

```bash
docker kill jira-cluster-db  # kill if already running
docker rm jira-cluster-db    # if exists already

docker run \
    --name jira-cluster-db \
    --net=jira-cluster \
    --net-alias=jira-cluster-db \
    -e POSTGRES_PASSWORD=jira \
    -e POSTGRES_USER=jira \
    -d postgres:9.4
```

 * Note: 
   * [JIRA Software 7.x supports max PostgreSQL 9.4](https://confluence.atlassian.com/adminjiraserver072/supported-platforms-828787550.html)


&nbsp;

**(5) Jira Nodes**

Start as many JIRA nodes as you want and increase the node-number each time.

```bash
rm -rf $(pwd)/jira-shared-home/* # clean shared jira-home if present

docker kill jira-cluster-node1   # kill if already running
docker rm jira-cluster-node1     # remove named image if exists

docker run \
    --name jira-cluster-node1 \
    --net=jira-cluster \
    --net-alias=jira-cluster-node1 \
    --env NODE_NUMBER=1 \
    -v $(pwd)/jira-shared-home:/jira-shared-home \
    -d codeclou/docker-atlassian-jira-data-center:jiranode-software-7.3.3
```

 * Note:
   * It might take up to 3 minutes for JIRA to startup. Check with `docker logs jira-cluster-node1`


&nbsp;

**(6) Loadbalancer** 

Start a sticky-session loadbalancer to all running JIRA nodes.
Set `NODES` to the amount of nodes you started.

```bash
docker rm jira-cluster-lb # if exists already

docker run \
    --name jira-cluster-lb \
    --net=jira-cluster \
    --net-alias=jira-cluster-lb \
    --env NODES=2 \
    -p 9980:9980 \
    -d codeclou/docker-atlassian-jira-data-center:loadbalancer
```

&nbsp;

**(7) Check Containers**

Check if all containers have started with:

`docker ps --format '{{.ID}}\t{{.Names}}\t\t{{.Ports}}'`

Should show something like:

```
101c71ae0c12    jira-cluster-node1     4446/tcp, 8080/tcp, 40001/tcp
72f92316309f    jira-cluster-lb        0.0.0.0:9980->9980/tcp
62fba1910763    jira-cluster-node2     4446/tcp, 8080/tcp, 40001/tcp
e2e9a6b1b757    jira-cluster-db        5432/tcp
```

&nbsp;

**(8) Start Configuration**

Once the cluster is fully started up, you need to configure JIRA Software in the browser.

Go to **[http://jira-cluster-lb:9980/](http://jira-cluster-lb:9980/)** and make sure you enabled cookies (sticky session).

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-01-allow-cookies.png" width="80%"></p>

Use `http://jira-cluster-lb:9980` as Base URL.

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-02-baseurl.png" width="80%"></p>

You can either use a [Atlassian Data Center Timebomb Licenses](https://developer.atlassian.com/market/add-on-licensing-for-developers/timebomb-licenses-for-testing)
or at best get a JIRA Software Data Center 30 Days Trial License from [my.atlassian.com](https://my.atlassian.com/product).

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-03-license.png" width="80%"></p>

Configure your user.

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-04-username.png" width="80%"></p>

Skip E-Mail Setup and click yourself through to the end of the installation.

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-05-email-later.png" width="80%"></p>

Check if clustering is activated under `System`  → `System Info` and search for `Clustering`

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-06-systeminfo-clustering-on.png" width="80%"></p>

Use the [JIRA Data Center Health Check Tools](https://confluence.atlassian.com/enterprise/jira-data-center-health-check-tools-644580752.html)
to check the Health of each cluster node. `System`  → `Atlassian Support Tools` → `Health Checks tab`

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-07-health-checks.png" width="80%"></p>

Check if all nodes are active and alive under `System`  → `System Info` and search for `Cluster Nodes`

<p align="center"><img src="https://codeclou.github.io/docker-atlassian-jira-data-center/img/cluster-09-systeminfo-all-nodes-active.png?v2" width="80%"></p>

If not all nodes you have started are active, try restarting all nodes not showing up (docker kill, docker run).

&nbsp;

Now your cluster should be up and running.

-----

&nbsp;

### FAQ

**Why not use Docker Swarm Mode?**

 * Because we need a sticky session loadbalancer, and the whole idea of swarm mode is to have identical 
stateless worker nodes. JIRA Data Center on the other hand relies on a state for each node.

&nbsp;

-----

&nbsp;

### License

[MIT](./LICENSE) © [Bernhard Grünewaldt](https://github.com/clouless)
  
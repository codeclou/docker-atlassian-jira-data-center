# docker-atlassian-jira-data-center

Dockerized [Atlassian JIRA® Data Center](https://de.atlassian.com/enterprise/data-center) for local testing during plugin development.

-----

&nbsp;

### Prerequisites


 * Runs as non-root with fixed UID 10777 and GID 10777. See [howto prepare volume permissions](https://github.com/codeclou/doc/blob/master/docker/README.md).
 * See [howto use SystemD for named Docker-Containers and system startup](https://github.com/codeclou/doc/blob/master/docker/README.md).

-----

&nbsp;

### Usage with Docker Compose

Start a JIRA Data Center with one loadbalancer, two JIRA nodes and a PostgreSQL Database.

```
git clone https://github.com/codeclou/docker-atlassian-jira-data-center.git
cd docker-atlassian-jira-data-center
docker-compose up
```

Goto: http://localhost:9980/

-----

&nbsp;

### Usage with Docker

Direct usage with `docker run`.

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

**(3) PostgreSQL Database**

Start the Database

```bash
docker kill jira-cluster-db  # if exists already
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

**(4) Jira Nodes**

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

**Start Loadbalancer** linked to three running named JIRA nodes

```bash
docker rm jira-cluster-lb # if exists already

docker run -i \
    --name jira-cluster-lb \
    --link jira-cluster-node1 \
    --link jira-cluster-node2 \
    --link jira-cluster-node3 \
    --env NODES=3 \
    -p 9980:9999 \
    codeclou/docker-atlassian-jira-data-center:loadbalancer
```

 docker ps --format '{{.ID}}\t{{.Names}}\t\t{{.Ports}}'
 
 * Convention is that it loadbalances to `http://jira-cluster-node1:8080, http://jira-cluster-node2:8080, ..., http://jira-cluster-nodeN:8080` with `N` being `NODES` ENV-variable.
 * Loadbalancer-URL: http://localhost:9980/
 * Note:
   * JIRA Nodes must be started before the loadbalancer.
   * Do not use `-t` since it will kill the foreground apache2.



&nbsp;

See the `start-cluster.sh` for a fully automated script to start a cluster.

Once the cluster ist fully started up, you need to start post configuration:

 * **[http://jira-cluster-lb:9980/](http://jira-cluster-lb:9980/)**
 * [Atlassian Data Center Timebomb Licenses](https://developer.atlassian.com/market/add-on-licensing-for-developers/timebomb-licenses-for-testing)
 * Tip: At best use a JIRA Software Data Center 30 Days Trial License from my.atlassian.com


![](https://codeclou.github.io/docker-atlassian-jira-data-center/img/post-config-jira-data-center.gif?v2)

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
  
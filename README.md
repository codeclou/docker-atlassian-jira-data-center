# docker-atlassian-jira-data-center

Dockerized [Atlassian JIRA® Data Center](https://de.atlassian.com/enterprise/data-center) for local testing during plugin development.

-----

&nbsp;

### Prerequisites


 * Runs as non-root with fixed UID 10777 and GID 10777. See [howto prepare volume permissions](https://github.com/codeclou/doc/blob/master/docker/README.md).
 * See [howto use SystemD for named Docker-Containers and system startup](https://github.com/codeclou/doc/blob/master/docker/README.md).
 * You should get some [Atlassian Data Center Timebomb Licenses](https://developer.atlassian.com/market/add-on-licensing-for-developers/timebomb-licenses-for-testing) for testing

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

**Start PostgreSQL Database**

```bash
docker kill jira-cluster-db # if exists already
docker rm jira-cluster-db # if exists already

docker run \
    --name jira-cluster-db \
    -e POSTGRES_PASSWORD=jira \
    -e POSTGRES_USER=jira \
    -d postgres:9.4
```

 * Note: 
   * [JIRA Software 7.x supports max PostgreSQL 9.4](https://confluence.atlassian.com/adminjiraserver072/supported-platforms-828787550.html)


&nbsp;

**Start Jira Nodes**

```bash
docker kill jira-cluster-node1   # kill if already running
docker rm jira-cluster-node1     # remove named image if exists
rm -rf $(pwd)/jira-shared-home/* # clean shared jira-home if present

docker run -i -t \
    --name jira-cluster-node1 \
    --link jira-cluster-db \
    --add-host jira-cluster-node1:127.0.0.1 \
    --env NODE_NUMBER=1 \
    -v $(pwd)/jira-shared-home:/jira-shared-home \
    codeclou/docker-atlassian-jira-data-center:jiranode-software-7.3.3
```

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

 
 * Convention is that it loadbalances to `http://jira-cluster-node1:8080, http://jira-cluster-node2:8080, ..., http://jira-cluster-nodeN:8080` with `N` being `NODES` ENV-variable.
 * Loadbalancer-URL: http://localhost:9980/
 * Note:
   * JIRA Nodes must be started before the loadbalancer.
   * Do not use `-t` since it will kill the foreground apache2.



&nbsp;

Once the cluster ist fully started up, you need to start post configuration

![](https://codeclou.github.io/docker-atlassian-jira-data-center/img/post-config-jira-data-center.gif)

-----

&nbsp;

### FAQ

**Why not use Docker Swarm Mode?**

 * Because we need a sticky session loadbalancer, and the whole idea of swarm mode is to have identical 
stateless worker nodes. JIRA Data Center on the other hand relies on a state for each node.

&nbsp;

**Why am I getting Healthcheck Connection refused Exceptions?**

```
2017-03-25 17:11:10,314 SupportHealthCheckThread-3 ERROR ServiceRunner     [c.a.j.p.healthcheck.support.BaseUrlHealthCheck] An error occurred when performing the Base URL healthcheck:
org.apache.http.conn.HttpHostConnectException: Connect to localhost:9980 [localhost/127.0.0.1] failed: Connection refused (Connection refused)
```

Why is this happening?

 * This is due to the jira-node wanting to connect to the healthcheak via the configured **baseUrl** which is `localhost:9980`. But from inside the node this is not reachable, since 9980 belongs to the loadbalancer.
 * Generally you can ignore this, but if you want it fixed you can do the following.

Solution 

 * Put in your hosts `/etc/hosts` the following: `127.0.0.1 jira-cluster-lb`
 * Start your nodes with `--add-host jira-cluster-lb:192.168.178.4`. Put your actual Network IP there.
 * Browse to your cluster on `http://jira-cluster-lb:9980/` and configure the baseURL in Settings this way.



-----

&nbsp;

### License

[MIT](./LICENSE) © [Bernhard Grünewaldt](https://github.com/clouless)
  
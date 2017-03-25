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
    -d postgres:9.6
```


&nbsp;

**Start Jira Nodes**

```bash
docker kill jira-cluster-node1 # if exists already
docker rm jira-cluster-node1 # if exists already

docker run -i \
    --name jira-cluster-node1 \
    --link jira-cluster-db \
    --add-host jira-cluster-node1:127.0.0.1 \
    --env NODE_NUMBER=1 \
    -v $(pwd)/jira-shared-home:/jira-shared-home \
    codeclou/docker-atlassian-jira-data-center:jiranode
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




-----

&nbsp;

### FAQ

**Why not use Docker Swarm Mode?**

 * Because we need a sticky session loadbalancer, and the whole idea of swarm mode is to have identical 
stateless worker nodes. JIRA Data Center on the other hand relies on a state for each node.


-----

&nbsp;

### License

[MIT](./LICENSE) © [Bernhard Grünewaldt](https://github.com/clouless)
  
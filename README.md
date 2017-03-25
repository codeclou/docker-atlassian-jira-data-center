# docker-atlassian-jira-data-center

Dockerized [Atlassian JIRA® Data Center](https://de.atlassian.com/enterprise/data-center) for local testing during plugin development.

-----

&nbsp;

## Usage with Docker Compose

Start a JIRA Data Center with one loadbalancer, two JIRA nodes and a PostgreSQL Database.

```
git clone https://github.com/codeclou/docker-atlassian-jira-data-center.git
cd docker-atlassian-jira-data-center
docker-compose up
```

Goto: http://localhost:9980/

-----

&nbsp;

## Usage with Docker

Direct usage with `docker run`.

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

 
 * Convention is that it loadbalances to `http://jira-cluster-node1:9999, http://jira-cluster-node2:9999, ..., http://jira-cluster-nodeN:9999` with `N` being `NODES` ENV-variable.
 * Loadbalancer-URL: http://localhost:9980/
 * Note:
   * JIRA Nodes must be started before the loadbalancer.
   * Do not use `-t` since it will kill the foreground apache2.

-----

&nbsp;

## FAQ

### Why not use Docker Swarm Mode?

Because we need a sticky session loadbalancer,
and the whole idea of swarm mode is to have identical 
sateless worker nodes. JIRA Data Center on the other hand
relies on a state for each node.


-----

&nbsp;

### License

[MIT](./LICENSE) © [Bernhard Grünewaldt](https://github.com/clouless)
  
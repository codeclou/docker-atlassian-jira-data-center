# Sticky Session Loadbalancer

for Jira Data Center Cluster.

### Build

```
cd docker-atlassian-jira-data-center/loadbalancer/
docker build . -t loadbalancer:v2
```

### Deployment

Automatically built and deployed to docker hub via Jenkins.
With git commit ID as version. See `../Jenkinsfile`

### Use

see e.g. `../versions/8.4.0/docker-compose.yml`

.

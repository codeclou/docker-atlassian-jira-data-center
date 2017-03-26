# Development Documentation


## Releasing, Tagging

### Docker Images

Create a tag for each JIRA Version

```bash
# create tag
git tag -a jiranode-software-7.3.3 -m "jiranode-software-7.3.3"
git push origin jiranode-software-7.3.3

# remove tag
git tag -d jiranode-software-7.3.3
git push origin :refs/tags/jiranode-software-7.3.3
```

:bangbang: Each `jiranode-software-{version}` git-tag must have corresponding loadbalancer and jiranode tagged images
 
 * ![](https://codeclou.github.io/docker-atlassian-jira-data-center/img/jira-node-tag-dockerhub.png?v2)
 
&nsbp;

### Manage Cluster Script

Tag separately:

```bash
git tag -a manage-jira-cluster-1.0.0 -m "manage-jira-cluster-1.0.0"
git push origin manage-jira-cluster-1.0.0
```

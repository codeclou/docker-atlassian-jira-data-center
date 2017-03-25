# Development Documentation


## Releasing, Tagging, Dockerhub


### jiranode

Create a tag for each JIRA Version

```bash
# create tag
git tag -a jiranode-software-7.3.3 -m "jiranode-software-7.3.3"
git push origin jiranode-software-7.3.3

# remove tag
git tag -d jiranode-software-7.3.3
git push origin :refs/tags/jiranode-software-7.3.3
```

:bangbang: Each `jiranode-software-{version}` tag must have a corresponding
 
 * ![](https://codeclou.github.io/docker-atlassian-jira-data-center/img/jira-node-tag-dockerhub.png)
 
 &nbsp;
 
 ### loadbalancer
 
 Can stay on master only since it does not have much logic.
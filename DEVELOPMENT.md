# Internal Development Documentation

## Dockerhub Build Settings
 
![](https://codeclou.github.io/docker-atlassian-jira-data-center/img/jira-node-tag-dockerhub.png?v2)

## Management Script

**Update Check and Versioning**

  * When making changes to the management script, do:
  * (1) increase integer in `manage-jira-cluster-7.3.3-version.txt`
  * (2) increase integer in `manage-jira-cluster-7.3.3.sh` in var `MANAGEMENT_SCRIPT_VERSION`

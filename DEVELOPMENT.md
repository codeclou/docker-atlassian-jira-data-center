# Internal Development Documentation

## Jenkins

We build with our own Jenkins and push to docker hub.

Jenkins Pipeline Job Config:

 * https://github.com/codeclou/docker-common-build


## Management Script

**Update Check and Versioning**

  * When making changes to the management script, do:
  * (1) increase integer in `manage-jira-cluster-7.3.3-version.txt`
  * (2) increase integer in `manage-jira-cluster-7.3.3.sh` in var `MANAGEMENT_SCRIPT_VERSION`

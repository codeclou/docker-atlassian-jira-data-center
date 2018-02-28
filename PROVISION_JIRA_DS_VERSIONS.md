# How to create new version for new JIRA Version


### (0) Install provision script

```
cp provision-jira-ds-versions.sh /usr/local/bin/
chmod +x /usr/local/bin/

mkdir ~/.provision-jira-ds-versions-workdir/
```

Note that:

 * script will need you to be authenticated for all GitHub Repos cloned.
 * docker needs to be installed
 * script will clone git repos to `~/.provision-jira-ds-versions-workdir/`





&nbsp;

### (1) Create new JIRA Software base Image

For every new DataCenter version we first need a new base image in [codeclou/docker-atlassian-base-images](https://github.com/codeclou/docker-atlassian-base-images) repo.

```
                               # WHAT              # OLD   # NEW
provision-jira-ds-versions.sh  base-image          7.7.0   7.8.0
```

What the script will do:

 * (1) clone the repo
 * (2) branch off of oldVersion to newVersion branch
 * (3) replace version strings in files
 * (4) builds docker image locally (for testing only)
 * (5) asks if you want to push changes to remote

What you will need to do:

 * (1) check docker hub to see if [build for branch succeeds](https://hub.docker.com/r/codeclou/docker-atlassian-base-images/builds/)







&nbsp;

### (2) Create new management scripts

```
                               # WHAT              # OLD   # NEW
provision-jira-ds-versions.sh  management-scripts  7.7.0   7.8.0
```

What the script will do:

 * (1) clone the repo
 * (2) copy version folder containing script to new version folder
 * (3) replace version strings in files
 * (4) asks if you want to push to remote

What you will need to do:

 * (1) Check repo if scripts have been created correctly

Script Preview:

:bangbang: FIXME !!!

![](./docs/provision/provision-management-scripts.png)








&nbsp;

### (3) Create jiranode-{VRSN} branch and docker image

```
                               # WHAT        # OLD   # NEW
provision-jira-ds-versions.sh  jiranode      7.7.0   7.8.0
```

What the script will do:

 * (1) clone the repo
 * (2) checkout branch jiranode-{lastVersion}
 * (3) branch off jiranode-{newVersion}
 * (4) replace version strings in files
 * (5) builds docker image locally (for testing only)
 * (6) asks if you want to push to remote

What you will need to do:

 * (1) check docker hub to see if [build for branch succeeds](https://hub.docker.com/r/codeclou/docker-atlassian-jira-data-center/builds/)




 &nbsp;

 ### (4) Create loadbalancer-{VRSN} branch and docker image

 ```
                                # WHAT              # OLD   # NEW
 provision-jira-ds-versions.sh  loadbalancer        7.7.0   7.8.0
 ```

 What the script will do:

  * (1) clone the repo
  * (2) checkout branch loadbalancer-{lastVersion}
  * (3) branch off loadbalancer-{newVersion}
  * (4) replace version strings in files
  * (5) builds docker image locally (for testing only)
  * (6) asks if you want to push to remote

 What you will need to do:

  * (1) check docker hub to see if [build for branch succeeds](https://hub.docker.com/r/codeclou/docker-atlassian-jira-data-center/builds/)

#!/bin/bash

# USAGE "bash new-version.sh  8.6.0  8.8.0"

####################################################################################
# MIT License
# Copyright (c) 2018 Bernhard Grünewaldt
# See https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/LICENSE
####################################################################################

set -e

####################################################################################
#
# VARS
#
####################################################################################

# script params
LAST_VERSION=$1
NEW_VERSION=$2

# internal vars
script_version="2020-03-22 18:52"

# new feature: to be able to use versions like "8.0.0-m0030-beta" and the dotfree version still being "800" 
#              we changed the NEW_VERSION_NO_DOTS regex on 2018-12-31
NEW_VERSION_NO_DOTS=$(echo $NEW_VERSION | sed -e 's/^\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\).*$/\1\2\3/g')
#-
LAST_VERSION_NO_DOTS=${LAST_VERSION//[.]/}

####################################################################################
#
# COLORS
#
####################################################################################

export CLICOLOR=1
C_RED='\x1B[31m'
C_CYN='\x1B[96m'
C_GRN='\x1B[32m'
C_MGN='\x1B[35m'
C_RST='\x1B[39m'

####################################################################################
#
# FUNCTIONS
#
####################################################################################

# Used to be able to use pass-by-reference in bash
#
#
return_by_reference() {
    if unset -v "$1"; then
        eval $1=\"\$2\"
    fi
}

# Replace str1 in file by str2
#
# @param $1 {string} str1
# @param $2 {string} str2
# @param $3 {string} file
function replace_in_file {
  str1=$1
  str2=$2
  file=$3
  echo -e $C_GRN"   replace   : ${C_CYN}${str1}${C_RST} by ${C_CYN}${str2}${C_RST} in ${C_CYN}${file}${C_RST}${C_RST}"
  # Usage with .bak is compatible to macOS and normal linux
  sed -i .bak "s/${str1}/${str2}/g" ${file}
  rm -f ${file}.bak
}

# Rename oldFileName by newFileName
#
# @param $1 {string} oldFileName
# @param $2 {string} newFileName
function rename_file {
  oldFileName=$1
  newFileName=$2
  echo -e $C_GRN"   renaming  : ${C_CYN}${oldFileName}${C_RST} to ${C_CYN}${newFileName}${C_RST}${C_RST}"
  mv ${oldFileName} ${newFileName}
}

# Clone folder dirToClone to dirNameToCloneTo
#
# @param $1 {string} dirToClone
# @param $2 {string} dirNameToCloneTo
function clone_dir {
  dirToClone=$1
  dirNameToCloneTo=$2
  echo -e $C_GRN"   clone dir : ${C_CYN}${dirToClone}${C_RST} to ${C_CYN}${dirNameToCloneTo}${C_RST}${C_RST}"
  cp -r ${dirToClone} ${dirNameToCloneTo}
}


# Print action header
#
# @param $1 {string} actionname
function print_action_header {
  echo -e $C_MGN">>${C_RST}"
  echo -e $C_MGN">> ACTION: ${1} >  ${LAST_VERSION} -> ${NEW_VERSION} ${C_RST}"
  echo -e $C_MGN">>${C_RST}"
  echo ""
}


#
#
#
function confirm_git_add_and_commit {
  function management_scripts_do_git_addcommit {
      git add . -A
      git commit -m "automated creation of version ${NEW_VERSION}"
      echo -e $C_GRN"   adding new files and comitting. Ready to push to remote."${C_RST}
  }
  function management_scripts_cancel_git_addcommit {
    echo -e $C_RED"   skipping add and commit. no files staged! EXIT."${C_RST}
    exit 1
  }
  git status
  echo -e $C_CYN">> Do you wish to add and commit changes?${C_RST}"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) management_scripts_do_git_addcommit; break;;
          No ) management_scripts_cancel_git_addcommit; exit;;
      esac
  done
}

#
# SCRIPT HEADER
#
echo ""
echo -e $C_MGN'°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸'$C_RST
echo ""
echo -e $C_GRN'  Create new versions of Jira Software Data Center docker-compose files'$C_RST
echo -e $C_CYN"  version $script_version"$C_RST
echo ""
echo -e $C_MGN'°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸'$C_RST
echo ""

#
# PREREQUISITES
#
if [ ! -d ~/.provision-confluence-ds-versions-workdir/ ]
then
    mkdir ~/.provision-confluence-ds-versions-workdir/
fi




print_action_header "new docker-compose files"
echo -e $C_CYN">> trying to clone master branch${C_RST}"
cd ~/.provision-jira-ds-versions-workdir/
if [ -d "docker-atlassian-jira-data-center___master-branch" ]
then
rm -rf docker-atlassian-jira-data-center___master-branch
fi
git clone https://github.com/codeclou/docker-atlassian-jira-data-center.git docker-atlassian-jira-data-center___master-branch
cd docker-atlassian-jira-data-center___master-branch
git checkout master > /dev/null 2>&1
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" == "master" ]
then
echo -e $C_GRN"   we are on master branch ...${C_RST}"
else
echo -e $C_RED"   we are NOT on master branch. EXIT${C_RST}"
exit 1
fi

echo ""
echo -e $C_CYN">> trying to create new version ${NEW_VERSION} from old version ${LAST_VERSION}.${C_RST}"

if [ -d "versions/${NEW_VERSION}" ]
then
echo -e $C_RED"   new version ${NEW_VERSION} already exists. EXIT${C_RST}"
exit 1
else
echo -e $C_GRN"   new version ${NEW_VERSION} does not yet exist. CONTINUE${C_RST}"
fi
echo ""

clone_dir versions/${LAST_VERSION} versions/${NEW_VERSION}

cd versions/${NEW_VERSION}
replace_in_file ${LAST_VERSION}           ${NEW_VERSION}           docker-compose-four-nodes.yml
replace_in_file ${LAST_VERSION}           ${NEW_VERSION}           docker-compose-three-nodes.yml
replace_in_file ${LAST_VERSION}           ${NEW_VERSION}           docker-compose-two-nodes.yml
replace_in_file ${LAST_VERSION}           ${NEW_VERSION}           docker-compose-one-node.yml
replace_in_file ${LAST_VERSION_NO_DOTS}   ${NEW_VERSION_NO_DOTS}   docker-compose-four-nodes.yml
replace_in_file ${LAST_VERSION_NO_DOTS}   ${NEW_VERSION_NO_DOTS}   docker-compose-three-nodes.yml
replace_in_file ${LAST_VERSION_NO_DOTS}   ${NEW_VERSION_NO_DOTS}   docker-compose-two-nodes.yml
replace_in_file ${LAST_VERSION_NO_DOTS}   ${NEW_VERSION_NO_DOTS}   docker-compose-one-node.yml

replace_in_file ${LAST_VERSION}           ${NEW_VERSION}           README.md
replace_in_file ${LAST_VERSION_NO_DOTS}   ${NEW_VERSION_NO_DOTS}   README.md


cd ../../

confirm_git_add_and_commit
git push

# cleanup
rm -rf docker-atlassian-jira-data-center___master-branch
echo ""



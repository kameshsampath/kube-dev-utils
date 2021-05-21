#!/bin/bash

set -ex
set -o pipefail

SCRIPT_NAME=change-default-admin-passwd
NEXUS_URL=${NEXUS_URL:-'http://localhost:8081'}
NEXUS_NS=nexus3
NEXUS_ADMIN_NEW_PASSWD=admin123

echo "Jai Guru"

function nexus3_pod() {
  kubectl get pods -n $NEXUS_NS -lapp=nexus \
    | awk 'NR==2{print $1}'
}

function check_if_script_exists(){
  local http_code
  http_code="$(curl -s -o /dev/null -I -w '%{http_code}' -X GET -u admin:$ADMIN_PWD $NEXUS_URL/service/rest/v1/script/$SCRIPT_NAME)"
  echo "$http_code"
}

function update_password(){
 local http_code
 http_code="$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: text/plain' -u admin:$ADMIN_PWD $NEXUS_URL/service/rest/v1/script/$SCRIPT_NAME/run -d $NEXUS_ADMIN_NEW_PASSWD)"
 echo "$http_code"
}

if [ -z "$(nexus3_pod)" ];
then
  echo "Nexus Pod not found"
  exit 1
else
  
  ADMIN_PWD=$(kubectl exec -n $NEXUS_NS "pod/$(nexus3_pod)" -- cat /nexus-data/admin.password)

  if [ "200" != "$(check_if_script_exists)" ];
  then 
    echo "Creating script"
    curl -v -X POST --header "Content-Type: application/json" -u "admin:$ADMIN_PWD" "$NEXUS_URL/service/rest/v1/script" -d@script.json
  else
    echo "Updating script"
    curl -v -X PUT --header "Content-Type: application/json" -u "admin:$ADMIN_PWD" "$NEXUS_URL/service/rest/v1/script/$SCRIPT_NAME" -d@script.json
  fi

  printf "\nUpdating the password\n"

  if [ "200" == "$(update_password)" ];
  then
    printf "\n Password updated successfully \n"
  else
    printf "\n Password updated failed \n"
  fi
fi
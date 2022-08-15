#! /usr/bin/env bash

set -uo pipefail

unset KUBECONFIG

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
NEXUS_NS=${NEXUS_NS:-default}
NEXUS_DEPLOYMENT=${NEXUS_DEPLOYMENT:-nexus3}
NEXUS_SCRIPTS=("anonymous-access" "update-admin-password" "my-docker-registry")
NEXUS_URL=${NEXUS_URL:-'http://localhost:8081'}
NEXUS_ADMIN_PASSWD=${NEXUS_ADMIN_PASSWD:-admin123}
ANONYMOUS_ACCESS=${ANONYMOUS_ACCESS:-false}

function is_api_ready(){
  printf "\n Waiting for Nexus API to be Ready\n"

  res_code=$(curl --silent --fail --output /dev/null -w '%{http_code}' "${NEXUS_URL}")

  until [ "$res_code" -ne 000 ] &&  [ "$res_code" -lt 400 ];
  do
    sleep 5
    res_code=$(curl --silent --fail --output /dev/null -w '%{http_code}' "${NEXUS_URL}")
  done
  
  printf "\n Nexus API Ready\n"
}

function wait_for_nexus() {
  kubectl rollout status -n "$NEXUS_NS" deploy/"$NEXUS_DEPLOYMENT" --timeout=120s
}

function check_if_script_exists(){
  local http_code
  http_code="$(curl -s -o /dev/null -I -w '%{http_code}' -X GET -u admin:$1 $NEXUS_URL/service/rest/v1/script/$2)"
  printf  "Script %s check returned %d" "$2" "$http_code"
}

function loadScripts(){
  echo "Loading scripts"
  
  local admin_pwd
  if [ -f  /nexus-data/admin.password ];
  then
    admin_pwd=$(cat /nexus-data/admin.password)
  else
    admin_pwd="${NEXUS_ADMIN_PASSWD}"
  fi

  for s in "${NEXUS_SCRIPTS[@]}"
  do 
    local script_json_file
    script_json_file=""${SCRIPT_DIR}/$s.json""
    local http_code
    http_code="$(check_if_script_exists $admin_pwd $s)"
    
    if [ "200" != "${http_code}" ];
    then 
      echo "Creating $s script"
      curl -v -X POST --header "Content-Type: application/json" \
        -u "admin:$admin_pwd" \
        -d@"$script_json_file" \
        "$NEXUS_URL/service/rest/v1/script"
    elif [ "${http_code}" -ne 404 ] && [ "${http_code}" -ne 410 ];
    then
      echo "Updating $s script"
      curl -v -X PUT --header "Content-Type: application/json" \
        -u "admin:$admin_pwd" \
        -d@"$script_json_file" \
        "$NEXUS_URL/service/rest/v1/script/$s"
    else
      printf "Error loading script %s error status %d" "$s" "$http_code"
      exit 1
    fi
  done
}

function run_script(){
 local http_code
 http_code="$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: text/plain' -u admin:$1 $NEXUS_URL/service/rest/v1/script/$2/run -d $3)"
 echo "$http_code"
}

function update_admin_password(){
  if [ -f /nexus-data/admin.password ];
  then
    local admin_pwd
    admin_pwd=$(cat /nexus-data/admin.password)
    printf "\nUpdating the password\n"
    if [ "200" == "$(run_script $admin_pwd 'update-admin-password' $NEXUS_ADMIN_PASSWD)" ];
    then
      printf "\n Password updated successfully \n"
      rm -f /nexus-data/admin.password
    else
      printf "\n Password updated failed \n"
    fi
  else
    printf "\n Skipping Password reset\n"
  fi
}

## Enable/Disable Anonymous Access
function set_anonymous_access() {
  local admin_pwd
  if [ -f  /nexus-data/admin.password ];
  then
    admin_pwd=$(cat /nexus-data/admin.password)
  else
    admin_pwd="${NEXUS_ADMIN_PASSWD}"
  fi

  if [ "200" == "$(run_script "$admin_pwd" 'anonymous-access' "${ANONYMOUS_ACCESS}")" ];
    then
      printf "\n Updated anonymous access \n"
    else
      printf "\n Anonymous access update failed \n"
  fi
}

function create_docker_registry() {
  local admin_pwd
  if [ -f  /nexus-data/admin.password ];
  then
    admin_pwd=$(cat /nexus-data/admin.password)
  else
    admin_pwd="${NEXUS_ADMIN_PASSWD}"
  fi

  if [ "200" == "$(run_script "$admin_pwd" 'my-docker-registry' "@${SCRIPT_DIR}/my-docker-registry-params.json")" ];
    then
      printf "\n Added default private docker registry \n"
    else
      printf "\n Adding private docker registry failed \n"
  fi
}

wait_for_nexus

# ensuring that the replicas are scaled down
kubectl scale --replicas=0  -n "$NEXUS_NS" deployment "$NEXUS_DEPLOYMENT"

if ! grep -qR 'nexus.scripts.allowCreation=true' /nexus-data/etc/nexus.properties
then
  if [ -w /nexus-data/etc/nexus.properties ];
  then
    echo "Scripting not enabled, enabling now."
    echo -n 'nexus.scripts.allowCreation=true' >> /nexus-data/etc/nexus.properties
  else
    echo "Cant write to file /nexus-data/etc/nexus.properties" 
    exit 1
  fi
fi

kubectl scale --replicas=1  -n "$NEXUS_NS" deployment "$NEXUS_DEPLOYMENT"

wait_for_nexus
is_api_ready
loadScripts
update_admin_password
set_anonymous_access
create_docker_registry

exit 0
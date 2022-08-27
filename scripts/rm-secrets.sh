#! /usr/bin/env bash

set -euxo pipefail

drone secret rm --name github_token "${KDU_DRONE_REPO}"

drone secret rm --name destination_image "${KDU_DRONE_REPO}"

drone secret rm --name image_registry "${KDU_DRONE_REPO}"

drone secret rm --name image_registry_user "${KDU_DRONE_REPO}"

drone secret rm --name image_registry_password "${KDU_DRONE_REPO}"
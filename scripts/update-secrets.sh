#! /usr/bin/env bash

set -euxo pipefail

drone secret update --name github_token --data "${GITHUB_TOKEN}" "${KDU_DRONE_REPO}"

drone secret update --name destination_image --data "${REPO}" "${KDU_DRONE_REPO}"

drone secret update --name image_registry --data "${REGISTRY_NAME}" "${KDU_DRONE_REPO}"

drone secret update --name image_registry_user --data "${IMAGE_REGISTRY_USER}" "${KDU_DRONE_REPO}"

drone secret update --name image_registry_password --data "${IMAGE_REGISTRY_PASSWORD}" "${KDU_DRONE_REPO}"
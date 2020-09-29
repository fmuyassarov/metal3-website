#!/bin/bash

METAL3_DIR="$(dirname "$(readlink -f "${0}")")/../.."

export ACTION="feature_test_provisioning"

"${METAL3_DIR}"/scripts/run.sh
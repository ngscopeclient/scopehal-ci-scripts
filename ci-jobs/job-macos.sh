#!/bin/bash
export BRANCH=$1
export COMMIT=$2

cd /Users/ci/Documents
git clone --recursive https://github.com/ngscopeclient/scopehal-apps
cd scopehal-apps
git checkout $COMMIT
./test-scripts/test-driver-macos.sh

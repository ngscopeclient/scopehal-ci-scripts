#!/bin/bash
git clone --recursive https://github.com/ngscopeclient/scopehal-apps
cd scopehal-apps
./test-scripts/test-driver-debian.sh

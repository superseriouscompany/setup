#!/bin/bash

# Exit on any error
set -e
# Grab reference to test folder
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}/" )" && pwd )
# Load assertion library
. ${DIR}/assert.sh

# Assert that installation puts sss in an executable path
which sss &> /dev/null && rm /usr/local/bin/sss &> /dev/null
assert "which sss"
${DIR}/../sss install
assert "which sss" "/usr/local/bin/sss"
assert_end installation

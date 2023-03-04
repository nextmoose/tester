#!/bin/sh

export IMPLEMENTATION_URL="${1}" &&
    export IMPLEMENTATION_POSTULATE="${2}" &&
    export TEST_URL="${3}" &&
    export TEST_POSTULATE="${4}" &&
    export TEST_REV="${5}" &&
    export DEFECT="${6}" &&
    export POSTULATE="${7}" &&
    export TOKEN="${8}" &&
    env &&
    echo BEFORE &&
    curl -L https://nixos.org/nix/install | sh &&
    echo AFTER

#!/bin/sh

echo BEFORE &&
    sh ${GITHUB_ACTION_PATH}/install-nix.sh &&
    echo AFTER &&
    env

#!/bin/sh

echo BEFORE &&
    ${ACTION_PATH}/install-nix.sh &&
    echo AFTER &&
    env

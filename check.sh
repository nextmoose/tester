#!/bin/sh

echo BEFORE &&
    sh ./install-nix.sh &&
    echo AFTER &&
    env

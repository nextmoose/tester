#!/bin/sh


IMPLEMENTATION_URL=${1} &&
    IMPLEMENTATION_POSTULATE=${2} &&
    TEST_URL=${3} &&
    TEST_POSTULATE=${4} &&
    TEST_REV=${5} &&
    DEFECT=${6} &&
    POSTULATE=${7} &&
    TOKEN=${8} &&
    env &&
    apt-get update

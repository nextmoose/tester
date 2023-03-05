#!/bin/bash

env &&
    echo &&
    echo &&
    echo POSTULATE=${POSTULATE} &&
    if [ -z "${POSTULATE}" ]
    then
	echo POSTULANT must not be blank. &&
	    exit 64
    elif [ ${POSTULATE} == true ]
    then
	echo Since POSTULATE is true we should bypass testing. &&
	    exit 0
    elif [ ${POSTULATE} == false ]
    then
	echo Since POSTULATE is false we should not bypass testing ... we should test,
    else
	echo POSTULATE must be either true or false &&
	    exit 64
    fi &&
    echo IMPLEMENTATION_POSTULATE=${IMPLEMENTATION_POSTULATE} &&
    if [ -z "${IMPLEMENTATION_POSTULATE}" ]
    then
	echo IMPLEMENTATION_POSTULANT must not be blank. &&
	    exit 64
    elif [ ${IMPLEMENTATION_POSTULATE} == true ]
    then
	echo Since IMPLEMENTATION_POSTULATE is true we should use this push as test disregarding the url.
    elif [ ${IMPLEMENTATION_POSTULATE} == false ]
    then
	echo Since IMPLEMENTATION_POSTULATE is false we should not use this push as test ... we should use the url.
    else
	echo IMPLEMENTATION_POSTULATE must be either true or false &&
	    exit 64
    fi &&
    echo TEST_POSTULATE=${TEST_POSTULATE} &&
    if [ -z "${TEST_POSTULATE}" ]
    then
	echo TEST_POSTULATE must not be blank. &&
	    exit 64
    elif [ ${TEST_POSTULATE} == true ]
    then
	echo Since TEST_POSTULATE is true we should use this push as test disregarding the url.
    elif [ ${TEST_POSTULATE} == "false" ]
    then
	 echo Since TEST_POSTULATE is false we should not use this push as test ... we should use the url.
    else
	echo TEST_POSTULATE must be either true or false &&
	    exit 64
    fi &&
    if [ "${IMPLEMENTATION_POSTULATE}" == "${TEST_POSTULATE}" ] && [ "${IMPLEMENTATION_POSTULATE}" == "true" ] && [ "${TEST_POSTULATE}" == "true" ]
    then
	echo Both IMPLEMENTATION_POSTULATE and TEST_POSTULATE can not be true &&
	    exit 64
    fi &&
    if [ "${IMPLEMENTATION_POSTULATE}" == "true" ]
    then
	IMPLEMENTATION=$( pwd )
    else
	IMPLEMENTATION=${IMPLEMENTATION_URL}
    fi &&
    if [ "${TEST_POSTULATE}" == "true" ]
    then
	TEST=$( pwd )
    else
	if [ -z "${TEST_REV}" ]
	then
	    TEST=${TEST_URL}
	else
	    TEST=${TEST_URL}?rev=${TEST_REV}
	fi
    fi &&
    ${ACTION_PATH}/install-nix.sh &&
    find ${HOME} -maxdepth 1 &&
    source ${HOME}/.bashrc &&
    which nix &&
    cd $( mktemp --directory ) &&
    git init &&
    git config user.name "No One" &&
    git config user.email "noone@nobody" &&
    nix flake init &&
    sed -e "s#\${IMPLEMENTATION}#${IMPLEMENTATION}#" -e "s#\${TEST}#${TEST}#" -e "wflake.nix" ${ACTION_PATH}/flake.nix &&    
    git add flake.nix &&
    git commit --all --message "" --allow-empty-message &&
    OBSERVED_DEFECT="$( nix develop --command check )" &&
    echo The observed defect is &&
    echo ${OBSERVED_DEFECT} &&
    echo The expected defect is &&
    echo ${DEFECT} &&
    if [ "${OBSERVED_DEFECT}" == "${DEFECT}" ]
    then
	The observed and expected defects are the same.
    else
	The observed and expected defects are different.
    fi

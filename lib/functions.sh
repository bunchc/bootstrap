#!/bin/bash -
#title          :functions.sh
#description    :Provides try/catch and logging for bash scripts
#author         :Cody Bunch
#date           :20170228
#version        :000
#usage          :source $path_to_file/functions.sh
#notes          :
#============================================================================

# Try/catch
try()
{
    [[ $- = *e* ]]; SAVED_OPT_E=$?
    set +e
}


throw()
{
    exit "$1"
}


catch()
{
    export ex_code=$?
    (( SAVED_OPT_E )) && set +e
    return $ex_code
}


throwErrors()
{
    set -e
}


ignoreErrors()
{
    set +e
}


#!/bin/bash

#https://codefather.tech/blog/bash-get-script-directory/
SCRIPT_RELATIVE_DIR=$(dirname "${BASH_SOURCE[0]}")

echo $SCRIPT_RELATIVE_DIR
cd $SCRIPT_RELATIVE_DIR
SCRIPT_FULL_PATH=$(pwd)
echo $SCRIPT_FULL_PATH


echo mkdir ../static/generated
mkdir ../static/generated

cp ../../../clients/spa/build/spa.js ../static/generated/
cp ../../../clients/spa/build/spa.css ../static/generated/

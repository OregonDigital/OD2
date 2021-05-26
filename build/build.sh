#!/bin/bash
#
# Script for manually building and pushing containers to the Regitry
#
#   Usage: build.sh <build number>
#   Input: BCR_PASS environment variable with the Registry password
#

build_no="$1"
tag_prefix="rordway"

if [ -z "$BCR_PASS" ]; then
   echo 'Please set the BCR password in $BCR_PASS'
   exit 1
fi

if [ -z "$build_no" ]; then
   if [ -f ".version" ]; then
      version=`cat .version`
      let build_no=($version + 1)
      echo "Using cached build number: (old: $version, new: $build_no)"
   else
      echo "Usage: $0 <build number>"
      exit 1
   fi
fi
build_args="--compress --build-arg RAILS_ENV=production --build-arg FEDORA_URL= --build-arg DEPLOYED_VERSION=${tag_prefix}-${build_no}"
tag1="registry.library.oregonstate.edu/od2_web:${tag_prefix}-${build_no}"

echo "Building for tag $tag1"
RAILS_ENV=$RAILS_ENV docker build ${build_args} . -t "$tag1"

#if [ "$?" -eq 0 ]; then
#   echo "Logging into BCR as admin"
#   echo $BCR_PASS | docker login --password-stdin registry.library.oregonstate.edu
#
#   echo "pushing: $tag1"
#   docker push "$tag1"
#   if [ "$?" -eq 0 ]; then
#      echo "$build_no" > .version
#   fi
#fi

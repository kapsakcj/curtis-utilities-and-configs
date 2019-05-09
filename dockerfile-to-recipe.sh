#!/bin/bash

# Purpose: to convert Dockerfiles to Singularity recipes using sypthon

# Requirements: spython - https://singularityhub.github.io/singularity-cli/install

# USAGE:
# must be two dirs up from your dockerfiles
# currently set to convert one dockerfile, will eventually put into a loop for all dockerfiles found two dirs down
#
# dockerfile-to-recipe.sh [path to dockerfile] [path to resulting singularity recipe]
#

# exit script if an error code is received or if a non-existent variable is referenced
set -eu

if [ -z $1 ]; then
  echo "you need to provide a path to your dockerfile"
  exit
else
  echo 'path to Dockerfile is set to:' $1
fi
dockerfileDir=$1
echo '$dockerfileDir set to:' $dockerfileDir

# check to see if dir specified for Singularity destination
if [ -z $2 ]; then
  echo "you need to provide a path to where the singularity recipe should go"
else
  echo 'path to Singularity recipe is set to:' $2
fi
recipeDest=$2
echo '$recipeDest set to:' $recipeDest

# set recipe name to Singularity.programName.version#.#.#
recipeSuffix=$(echo ${dockerfileDir} | sed 's_/_._' | sed 's_/_ _' )
echo '$recipeSuffix set to:' $recipeSuffix

# run spython to convert Dockerfile to Singularity recipe, name it Singularity
spython recipe $dockerfileDir/Dockerfile $recipeDest/Singularity.$recipeSuffix

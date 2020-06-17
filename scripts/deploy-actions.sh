#!/bin/bash

set -o errexit -o nounset

addToDrat(){
  mkdir drat; cd drat

  ## Set up Repo parameters
  git init
  git config user.name "StoXProject bot"
  git config user.email "stox@hi.no"
  git config --global push.default simple

  ## Get drat repo
  git remote add upstream "https://x-access-token:${DRAT_DEPLOY_TOKEN}@github.com/StoXProject/repo.git"

  # To prevent race condition, set a loop of adding and pushing file with Drat
  RET=1
  until [ $RET -eq 0 ]; do
    echo "Begin insert"
    git fetch upstream
    git checkout -f gh-pages
    cd ..
    Rscript -e "library(drat); insertPackage('./$PKG_FILE', \
      repodir = './drat', \
      commit=FALSE)"
    cd drat
    git add .
    git status
    git commit -m "Add ${PKG_FREL}: build ${BUILD_NUMBER}"
    git push && RET=$? || RET=$?
    sleep 1
    echo "End insert"
  done
  cd ..
}

addToDrat

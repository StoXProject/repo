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

  # To prevent race condition, set a loop of adding file with Drat
  RET=1
  until [ ${RET} -eq 0 ]; do
    git fetch upstream 2>err.txt
    git checkout -f gh-pages

    cd ..

    Rscript -e "library(drat); insertPackage('./$PKG_FILE', \
      repodir = './drat', \
      commit='Repo update ${PKG_FILE_PREFIX}: build $BUILD_NUMBER')"

    cd drat

    git push 2>err.txt
    RET=$?
    sleep 1
  done

  cd ..
}

addToDrat

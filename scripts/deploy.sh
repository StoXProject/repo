#!/bin/bash
set -o errexit -o nounset
cd ..

addToDrat(){
  mkdir drat; cd drat

  ## Set up Repo parameters
  git init
  git config user.name "StoXProject bot"
  git config user.email "stox@hi.no"
  git config --global push.default simple

  ## Get drat repo
  git remote add upstream "https://$API_KEY@github.com/StoXProject/repo.git"

  git fetch upstream 2>err.txt
  git checkout gh-pages

  if [ "${DEPLOY_SRC+x}" = x ]; then
    Rscript -e "library(drat); insertPackage('$PKG_REPO/drat/$PKG_TARBALL', \
      repodir = '.', \
      commit='Repo update $PKG_REPO: build $TRAVIS_BUILD_NUMBER')"
  fi

  if [ "${TRAVIS_BUILD_NUMBER+x}" = x ]; then
    export BUILD_NUMBER=$TRAVIS_BUILD_NUMBER
  else
    export BUILD_NUMBER=$APPVEYOR_BUILD_NUMBER
  fi

  Rscript -e "library(drat); insertPackage('$PKG_REPO/drat/$BINSRC', \
    repodir = '.', \
    commit='Repo update $PKG_REPO: build $BUILD_NUMBER')"
  git push 2>err.txt

}

addToDrat

cd $PKG_REPO

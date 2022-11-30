#!/bin/bash

# We automatically increment the package version for every successful pull request that merged to master
# This happens only if the current package version is already released (tagged)

PKGVER=$(sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGNAME=$(sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
TAG=${PKGNAME}-v${PKGVER}
PRERELEASE=$(echo ${TAG} | grep -e "[-].*[-]" -c)

echo "Looking for tag $TAG"

git fetch -f --tags

HEAD_COMMIT=$(git rev-parse HEAD)

IS_TAG=$((git show-ref --tags $TAG || echo "")| cut -d" " -f1)

echo "We have: $HEAD_COMMIT : $IS_TAG" 

if [[ -z ${IS_TAG} ||  $HEAD_COMMIT == $IS_TAG ]]; then
    echo "This version is not tagged yet or tagged in the current commit, we can always proceed."
else
    ## Find any existing tags
    #EXISTING_TAG=$(git tag --points-at $HEAD_COMMIT)
    #
    #if [[ -z $EXISTING_TAG ]]; then
    #    echo "We need to add sub-version increment"
    #    # Find how many development version are there
    #    NUM_TAG=$(git show-ref --tags | grep -F $PKGVER | wc -l)
    #    NUM_TAG=$((NUM_TAG + 9000 - 1))
    #    NEW_VER=${PKGVER}.${NUM_TAG}
    #else
    #    echo "Using existing development tag $EXISTING_TAG"
    #    NEW_VER=$(echo "$EXISTING_TAG" | sed "s/${PKGNAME}-v//g")
    #fi
    #
    #echo "New version is $NEW_VER"
    #sed -i -e "s/Version: *\([^ ]*\)/Version: ${NEW_VER}/g" DESCRIPTION
    #
    #export FINAL_TAG=${PKGNAME}-v${NEW_VER}
    #export PKG_FILE_PREFIX=${PKGNAME}_${NEW_VER}
    
    echo "Auto-increment disabled. This should be done with RstoxBuild instead."
fi

export FINAL_TAG=$TAG
export PKG_FILE_PREFIX=${PKGNAME}_${PKGVER}
export PRERELEASE=$PRERELEASE


echo "Final tag is $FINAL_TAG"

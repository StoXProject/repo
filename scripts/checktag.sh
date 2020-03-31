#!/bin/bash

# We automatically increment the package version for every successful pull request that merged to master
# This happens only if the current package version is already released (tagged)

PKGVER=$(sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGNAME=$(sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
TAG=${PKGNAME}-v${PKGVER}

echo "Looking for tag $TAG"

git fetch --tags

HEAD_COMMIT=$(git rev-parse HEAD)
IS_TAG=$(git show-ref --tags $TAG | cut -d" " -f1)

if [[ -z ${IS_TAG} ||  $HEAD_COMMIT == $IS_TAG ]]; then
    echo "This version is not tagged yet or tagged in the current commit, we can always proceed."
else
    # Find any existing tags
    EXISTING_TAG=$(git tag --points-at $HEAD_COMMIT)

    if [[ -z $EXISTING_TAG ]]; then
        echo "We need to add sub-version increment"
        # Find how many development version are there
        NUM_TAG=$(git show-ref --tags | grep -F $PKGVER | wc -l)
        NUM_TAG=$((NUM_TAG + 9000))
    else
        NUM_TAG=$(echo $EXISTING_TAG | sed "s/${PKGNAME}-v//g")
    fi

    echo "New version is $NUM_TAG"
    sed -i -e "s/Version: *\([^ ]*\)/Version: ${PKGVER}.${NUM_TAG}/g" DESCRIPTION
fi


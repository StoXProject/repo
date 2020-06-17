#!/bin/bash

set -o errexit -o nounset

rscript=$(cat <<EOF
install.packages("knitr", repos="https://cran.r-project.org");
library(knitr);

m <- read.dcf("src/contrib/PACKAGES");
srcTable <- knitr::kable(m[,c("Package","Version")]);


f1 <- function(pkgfilename) {
        tmp <- unlist(strsplit(pkgfilename, "/"));
        ver <- head(tail(tmp, 2), 1);
        os <- tail(head(tmp, 2), 1);

        m <- read.dcf(pkgfilename);
        m <- cbind(m, RVer=ver, OS=os);
        return(m[,c("Package", "RVer", "OS", "Version")]);
};

pkgfiles <- list.files("bin", pattern="PACKAGES$", recursive = T, full.names = T);

listpkg <- lapply(pkgfiles, f1);
tbl <- as.data.frame(do.call(rbind, listpkg));
tbl <- unique(tbl[order(tbl\$Package, tbl\$RVer, tbl\$OS),]);

binTable <-  knitr::kable(tbl, row.names = FALSE);
print(binTable);


txt <- paste(paste(srcTable), paste(binTable, collapse = "\n") , sep="\n");

sink("README.md");
cat("# Stox Project Package Repository\n", sep="\n");
cat(paste("\nUpdated on:", date()));
cat("\n## Source Packages\n", sep="\n");
cat(paste(srcTable), sep="\n");
cat("\n## Binary Packages\n", sep="\n");
cat(paste(binTable), sep="\n");
sink();
EOF
)

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

    # Run page generator
    echo $rscript | R --slave
    
    git add .
    git status
    git commit -m "Add ${PKG_FREL}: build ${BUILD_NUMBER}"
    git push && RET=$? || RET=$?
    git reset --hard upstream/gh-pages
    git clean -f -d
    sleep 1
    echo "End insert"
  done
  cd ..
}

addToDrat

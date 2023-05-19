#!/bin/bash
set -e

VERSION=prod
if [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9A-Za-z-]+ ]]
then
  helm package --version $VERSION --app-version $VERSION ./helm/$HELM_CHART_NAME
else
  echo "Tag from git is not semver compliant"
  exit 1
fi
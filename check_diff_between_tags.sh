#!/bin/bash
echo "Running..."
lambdaUpdate=false
for i in $(git diff --name-only $(git tag --sort version:refname | tail -n 2 | head -n 1) $(git tag --sort version:refname | tail -n 1))
do
  if [[ "$i" == *"lambda/"*  && !$lambdaUpdate ]];
  then
    lambdaUpdate=true
  fi
done

parsedTag=${GITHUB_REF##*/}

echo "::set-output name=lambdaUpdate::$lambdaUpdate"
echo "::set-output name=parsedTag::$parsedTag"
echo "Finished"



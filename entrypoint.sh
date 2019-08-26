#!/bin/bash

set -e

FOLDER=$1
GITHUB_USERNAME=$2
STARTER_NAME="${3:-'name'}"
BASE=$(pwd)

git config --global user.email "johno-actions-push-subdirectories@example.org"
git config --global user.name "$GITHUB_USERNAME"

echo "Cloning folders in $FOLDER and pushing to $GITHUB_USERNAME"

# sync to read-only clones
for folder in $FOLDER/*; do
  [ -d "$folder" ] || continue # only directories
  cd $BASE

  echo "Pushing $folder"

  NAME=$(cat $folder/package.json | jq --arg name "$STARTER_NAME" -r '.[$name]')
  CLONE_DIR="__${NAME}__clone__"

  # clone, delete files in the clone, and copy (new) files over
  # this handles file deletions, additions, and changes seamlessly
  git clone --depth 1 https://$API_TOKEN_GITHUB@github.com/$GITHUB_USERNAME/$NAME.git $CLONE_DIR &> /dev/null
  cd $CLONE_DIR
  find . | grep -v ".git" | grep -v "^\.*$" | xargs rm -rf # delete all files (to handle deletions in monorepo)
  cp -r $BASE/$folder/. .

  rm -rf yarn.lock
  yarn

  git add .
  git commit --message "Update $NAME from $GITHUB_REPOSITORY"
  git push origin master

  cd $BASE
done

#!/bin/bash

set -e

FOLDER=$1
GITHUB_USERNAME=$2
STARTER_NAME="${3:-name}"
BRANCH_NAME="${4:-main}"
RECURSIVE="${5:-true}"
BASE=$(pwd)

git config --global user.email "johno-actions-push-subdirectories@example.org"
git config --global user.name "$GITHUB_USERNAME"

echo "Cloning folders in $FOLDER and pushing to $GITHUB_USERNAME"
echo "Using $STARTER_NAME as the package.json key"

if [ "$RECURSIVE" = true ]; then
  # sync to read-only clones
  for folder in $FOLDER/*; do
    [ -d "$folder" ] || continue # only directories
    cd $BASE

    echo "$folder"

    NAME=$(cat $folder/package.json | jq --arg name "$STARTER_NAME" -r '.[$name]')
    echo "  Name: $NAME"
    IS_WORKSPACE=$(cat $folder/package.json | jq -r '.workspaces')
    CLONE_DIR="__${NAME}__clone__"
    echo "  Clone dir: $CLONE_DIR"

    # clone, delete files in the clone, and copy (new) files over
    # this handles file deletions, additions, and changes seamlessly
    git clone --depth 1 https://$API_TOKEN_GITHUB@github.com/$GITHUB_USERNAME/$NAME.git $CLONE_DIR &> /dev/null
    cd $CLONE_DIR
    find . | grep -v ".git" | grep -v "^\.*$" | xargs rm -rf # delete all files (to handle deletions in monorepo)
    cp -r $BASE/$folder/. .

    # generate a new yarn.lock file based on package-lock.json unless you're in a workspace
    if [ "$IS_WORKSPACE" = null ]; then
      echo "  Regenerating yarn.lock"
      rm -rf yarn.lock
      yarn
    fi

    # Commit if there is anything to
    if [ -n "$(git status --porcelain)" ]; then
      echo  "  Committing $NAME to $GITHUB_REPOSITORY"
      git add .
      git commit --message "Update $NAME from $GITHUB_REPOSITORY"
      git push origin $BRANCH_NAME
      echo  "  Completed $NAME"
    else
      echo "  No changes, skipping $NAME"
    fi

    cd $BASE
  done
fi

if [ "$RECURSIVE" = false ]; then
  # sync to read-only clones
    
    [ -d "$FOLDER" ] || continue # only directories
    cd $BASE

    echo "$FOLDER"

    NAME=$(cat $FOLDER/package.json | jq --arg name "$STARTER_NAME" -r '.[$name]')
    echo "  Name: $NAME"
    IS_WORKSPACE=$(cat $FOLDER/package.json | jq -r '.workspaces')
    CLONE_DIR="__${NAME}__clone__"
    echo "  Clone dir: $CLONE_DIR"

    # clone, delete files in the clone, and copy (new) files over
    # this handles file deletions, additions, and changes seamlessly
    git clone --depth 1 https://$API_TOKEN_GITHUB@github.com/$GITHUB_USERNAME/$NAME.git $CLONE_DIR &> /dev/null
    cd $CLONE_DIR
    find . | grep -v ".git" | grep -v "^\.*$" | xargs rm -rf # delete all files (to handle deletions in monorepo)
    cp -r $BASE/$FOLDER/. .

    # generate a new yarn.lock file based on package-lock.json unless you're in a workspace
    if [ "$IS_WORKSPACE" = null ]; then
      echo "  Regenerating yarn.lock"
      rm -rf yarn.lock
      yarn
    fi

    # Commit if there is anything to
    if [ -n "$(git status --porcelain)" ]; then
      echo  "  Committing $NAME to $GITHUB_REPOSITORY"
      git add .
      git commit --message "Update $NAME from $GITHUB_REPOSITORY"
      git push origin $BRANCH_NAME
      echo  "  Completed $NAME"
    else
      echo "  No changes, skipping $NAME"
    fi

    cd $BASE
fi

#!/bin/bash
FOLDER=$1
BASE=$(pwd)

# sync to read-only clones
for folder in $FOLDER/*; do
  [ -d "$folder" ] || continue # only directories
  cd $BASE

  NAME=$(cat $folder/package.json | jq -r '.name')
  CLONE_DIR="__${NAME}__clone__"

  # clone, delete files in the clone, and copy (new) files over
  # this handles file deletions, additions, and changes seamlessly
  git clone --depth 1 https://$GITHUB_API_TOKEN@github.com/$GITHUB_USERNAME/$NAME.git $CLONE_DIR
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

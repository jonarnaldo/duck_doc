#!/bin/bash
# see https://gist.github.com/dtolb/8189c858001f5fa30556509ba69b0b8d for example of implementation on Travis CI
# this will generate a markdown documentation file and place it in the documentation Folders
# in order for this to work:
#   you will need to install jsdoc2md for this this to work: https://github.com/jsdoc2md/jsdoc-to-markdown
#   provide origin folder where you would like to export from - this should be: ~/workspace/riffyn/unity/app/imports/client/ui/components/*
#   set destination of documentation folder where you would to to export to - this should be: ~/workspace/Documentation

# [ ] todo - how to handle errors if either location is not found
# [x] todo - generate/update readme.md when script is rerun
# [ ] todo - write script to create documentation from js files from both Unity and Core
# set variables if they don't exist

# n.b. home is /home/travis
# n.b. default directory is /home/travis/build/jonarnaldo/duck_doc

USEREMAIL="jonarnaldo@gmail.com"
USERNAME="jonarnaldo"
BASEURL="https://github.com/jonarnaldo"

TARGET_REPO="duck_typing"
CURRENT_REPO="duck_doc"

TARGET_FILES=$HOME/$TARGET_REPO/src/*
DESTINATION_FOLDER=$HOME/build/$USERNAME/$CURRENT_REPO/documentation

# writes jsdoc console output to markdown file
write_markdown_file () {
  local FILENAME
  FILENAME=$(basename $1) # strip directory from filename and save to local var
  DESTNAME=$(sed s/jsx/md/g <<< ${FILENAME}) # replace jsx to md in string

  # create or overwrite output to file ex. {destination}/foo.md
  echo "writing $DESTNAME to $DESTINATION_FOLDER"
  jsdoc2md $1 > $DESTINATION_FOLDER/$DESTNAME

  # append file with appropriate link in readme
  # ex. output: * [SimpleTable.jsx](SimpleTable.md)
  echo "* [${FILENAME}](${DESTNAME})" >> $DESTINATION_FOLDER/README.md
}

# export functions, set variables if they don't exist, clone repo, add jsdoc package
init() {
  echo "initiliazing updating documentation"
  export write_markdown_file
  export SHA=`git rev-parse --verify HEAD` # used for commit message

  # # clone repo into temp folder and cd into it
  cd $HOME
  git clone ${BASEURL}/${TARGET_REPO}.git
  cd ${TARGET_REPO}
  echo "moved into directory at ${PWD}"

  git checkout -b documentation
  sleep 5 # wait a bit to switch to branch
}

create_documentation () {
  echo "creating documentation..."
  find $TARGET_FILES -type f -name '*.jsx' ! -name '*.test.jsx' -exec bash -c 'write_markdown_file "$1"' - {} \;
}

setup_git() {
  echo "setting up config for git"
  git config --global user.email $USEREMAIL
  git config --global user.name $USERNAME
}

commit_documentation_files() {
  git add .
  echo "adding commit with message"
  git commit --message "documentation update: ${SHA}"
  echo "showing git commit log"
  git log
}

upload_files() {
  # git remote add origin-documentation https://${GH_TOKEN}@github.com/jonarnaldo/duck_doc.git > /dev/null 2>&1
  echo "uploading files to github..."
  git remote add origin-documentation https://${GH_TOKEN}@github.com/$USERNAME/$CURRENT_REPO.git
  git push --quiet --set-upstream origin-documentation documentation
  echo "uploaded files successfully!"
}

init
setup_git
create_documentation
sleep 30
commit_documentation_files
sleep 10
upload_files

exit
# setup_git
# commit_website_files
# upload_files

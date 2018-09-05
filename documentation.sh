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
add_markdown_file () {
  echo "adding markdown files"
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

export add_markdown_file
export SHA=`git rev-parse --verify HEAD` # used for commit message

# export functions, set variables if they don't exist, clone repo, add jsdoc package
init() {
  # # clone repo into temp folder and cd into it
  cd $HOME
  git clone ${BASEURL}/${TARGET_REPO}.git

  cd $HOME/build/$USERNAME/$CURRENT_REPO
  git checkout -b documentation
}

create_documentation () {
  jsdoc2md $HOME/$TARGET_REPO/src/game.js > $DESTINATION_FOLDER/game.md
  # find $TARGET_FILES -type f -name '*.jsx' ! -name '*.test.jsx' -exec bash -c \
  #   'echo "adding markdown files";
  #   local FILENAME;
  #   FILENAME=$(basename $1);
  #   DESTNAME=$(sed s/jsx/md/g <<< ${FILENAME});
  #   echo "writing $DESTNAME to $DESTINATION_FOLDER";
  #   jsdoc2md $1 > $DESTINATION_FOLDER/$DESTNAME;
  #   echo "* [${FILENAME}](${DESTNAME})" >> $DESTINATION_FOLDER/README.md' - {} \;
}

setup_git() {
  git config --global user.email $USEREMAIL
  git config --global user.name $USERNAME
}

commit_documentation_files() {
  git add .
  echo "adding commit with message 'documentation update: ${SHA}'"
  git commit --message "documentation update: ${SHA}"
  echo "commit log:"
}

upload_files() {
  git remote add origin https://${GH_TOKEN}@github.com/jonarnaldo/duck_doc.git > /dev/null 2>&1
  git push origin documentation

}

sleep 45
echo "initiliazing updating documentation"
init
sleep 20 # wait a bit to switch to branch
echo "setting up config for git"
setup_git
echo "creating documentation..."
create_documentation
sleep 30
commit_documentation_files
sleep 10
echo "uploading files to github..."
upload_files
echo "uploaded files successfully!"

exit
# setup_git
# commit_website_files
# upload_files

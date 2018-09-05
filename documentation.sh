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
${BASEURL:=https://github.com/jonarnaldo}
${REPO:=duck_typing}
${DESTINATIONFOLDER:=$HOME/documentation}
${TARGETFILES:=$HOME/src/*}

# overwrite readme file with updated info
echo "# Documentation"$'\r'$'\r' > $DESTINATIONFOLDER/README.md
echo "## Unity Component Table of Contents" >> $DESTINATIONFOLDER/README.md

# writes jsdoc console output to markdown file
write_markdown_file () {
  local FILENAME
  FILENAME=$(basename $1) # strip directory from filename and save to local var
  DESTNAME=$(sed s/jsx/md/g <<< ${FILENAME}) # replace jsx to md in string

  # write output to file ex. {destination}/foo.md
  # n.b. will create file if doesn't exist or overwrite existing file
  jsdoc2md $1 > ${DESTINATIONFOLDER}/${DESTNAME}

  # create appropriate link in readme
  # ex. output: * [SimpleTable.jsx](SimpleTable.md)
  echo "* [${FILENAME}](${DESTNAME})" >> $DESTINATIONFOLDER/README.md
}

# export functions, set variables if they don't exist, clone repo, add jsdoc package
init() {
  echo 'initiliazing updating documentation'
  export write_markdown_file
  export SHA=`git rev-parse --verify HEAD` # used for commit message

  echo home $HOME
  echo current directory $PWD

  # npm install -g jsdoc-to-markdown # adding jsdoc package
  #
  # # clone repo into temp folder and cd into it
  # cd ..
  # mkdir temp
  # cd temp
  # echo 'current directory' $PWD
  # git clone ${BASEURL}/${REPO}.git
  # cd ${REPO}
}

create_documentation () {
  cd $DESTINATIONFOLDER
  find $TARGETFILES -type f -name '*.jsx' ! -name '*.test.jsx' -exec bash -c 'write_markdown_file "$1"' - {} \;
}

setup_git() {
  git config --global user.email "jonarnaldo@gmail.com"
  git config --global user.name "jonarnaldo"
}

commit_documentation_files() {
  git checkout -b documentation
  git add .
  git commit --message "Travis build: ${SHA}"
}

upload_files() {
  git remote add origin-pages https://${GH_TOKEN}@github.com/MVSE-outreach/resources.git > /dev/null 2>&1
  git push --quiet --set-upstream documentation
}

init

exit
# setup_git
# commit_website_files
# upload_files

#!/bin/sh

APP_NAME="Sublime Text"
APP_DIR="/Applications/$APP_NAME.app"
SUBLIME_DIR="$HOME/Library/Application Support/Sublime Text 3"
LICENSE_FILE="$HOME/Library/Application Support/Sublime Text 2/Local/License.sublime_license"

if [ -d "$APP_DIR" ]
then
  echo 'Sublime Text 3 application found.'
else
  echo 'Sublime Text 3 not installed. Please install it to /Applications folder first.'
  echo '1) brew cask install sublime-text'
  echo '2) curl -fsSL http://git.io/sublime3-bootstrap | sh'
  exit 1
fi

# Add `subl` terminal command
command -v subl > /dev/null
if [ $? -eq 0 ]
then
  echo "Terminal command 'subl' already installed"
else
  CMD_PATH="/usr/local/bin"

  # sudo chown -R `whoami` /usr/local
  mkdir /usr/local/bin 2> /dev/null

  echo "Adding terminal command 'subl' into $CMD_PATH"
  ln -sf "$APP_DIR/Contents/SharedSupport/bin/subl" "$CMD_PATH/subl"

  if [[ :$PATH: != *:"$CMD_PATH":* ]] ; then
    echo "\033[0;31m ! \033[0m $CMD_PATH NOT found in \$PATH"
  fi
fi

# Install package control
# http://wbond.net/sublime_packages/package_control/installation#ST3

if [ -d "$SUBLIME_DIR/Installed Packages" ]
then
  echo 'Config directory found.'
else
  echo 'Creating config directory'
  open -g "$APP_DIR" && \
  sleep '0.5' && \
  osascript -e "tell application \"$APP_NAME\" to quit"
fi

if [ -d "$SUBLIME_DIR/Packages/Package Control" ]
then
  echo 'Package Control already installed.'
else
  echo 'Installing Package Control'

  curl --silent --show-error --fail --location \
    'https://packagecontrol.io/Package%20Control.sublime-package' \
    --output "$SUBLIME_DIR/Installed Packages/Package Control.sublime-package"
fi

echo 'Add default packages and configs...'

curl --silent --show-error --fail --location \
  'https://github.com/nicck/sublime-bootstrap/tarball/master' | \
  tar --strip 1 -zxvf - *-sublime-bootstrap-*/settings > /dev/null

cp -f ./settings/* "$SUBLIME_DIR/Packages/User/"
rm -rf ./settings

if [ -a "$LICENSE_FILE" ]
then
  echo 'Sublime Text 2 license file found.'
  cp "$LICENSE_FILE" "$SUBLIME_DIR/Local/License.sublime_license"
fi

echo "Done"
echo "Please wait ... (press ctrl-\` to see progress)" | subl -

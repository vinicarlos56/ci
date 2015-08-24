#!/bin/sh

echo "Downloading latest Atom release..."
curl -L "https://atom.io/download/deb" \
  -H 'Accept: application/octet-stream' \
  -o atom.deb

sudo apt-get install -y xorg xserver-xorg-video-dummy xinit
sudo echo 'Section "Device"
    Identifier  "Configured Video Device"
    Driver      "dummy"
EndSection

Section "Monitor"
    Identifier  "Configured Monitor"
    HorizSync 31.5-48.5
    VertRefresh 50-70
EndSection

Section "Screen"
    Identifier  "Default Screen"
    Monitor     "Configured Monitor"
    Device      "Configured Video Device"
    DefaultDepth 24
    SubSection "Display"
    Depth 24
    Modes "1024x800"
    EndSubSection
EndSection' >> /etc/X11/xorg.conf
export LC_ALL="en_US.utf-8"
export DISPLAY=:0.0
sudo xinit & 
sudo dpkg -i atom.deb
sudo apt-get -f -y install
# mkdir atom
# unzip -q atom.zip -d atom

# export PATH=$PWD/atom/Atom.app/Contents/Resources/app/apm/bin:$PATH

echo "Using Atom version:"
atom -v
# ATOM_PATH=./atom ./atom/Atom.app/Contents/Resources/app/atom.sh -v

echo "Downloading package dependencies..."
apm clean
apm install
# atom/Atom.app/Contents/Resources/app/apm/node_modules/.bin/apm clean
# atom/Atom.app/Contents/Resources/app/apm/node_modules/.bin/apm install

TEST_PACKAGES="${APM_TEST_PACKAGES:=none}"

if [ "$TEST_PACKAGES" != "none" ]; then
  echo "Installing atom package dependencies..."
  for pack in $TEST_PACKAGES ; do
    # atom/Aom.app/Contents/Resources/app/apm/node_modules/.bin/apm install $pack
    apm install $pack
  done
fi

if [ -f ./node_modules/.bin/coffeelint ]; then
  if [ -d ./lib ]; then
    echo "Linting package..."
    ./node_modules/.bin/coffeelint lib
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
  fi
  if [ -d ./spec ]; then
    echo "Linting package specs..."
    ./node_modules/.bin/coffeelint spec
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
  fi
fi

if [ -f ./node_modules/.bin/eslint ]; then
  if [ -d ./lib ]; then
    echo "Linting package..."
    ./node_modules/.bin/eslint lib
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
  fi
  if [ -d ./spec ]; then
    echo "Linting package specs..."
    ./node_modules/.bin/eslint spec
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
  fi
fi

if [ -f ./node_modules/.bin/standard ]; then
  if [ -d ./lib ]; then
    echo "Linting package..."
    ./node_modules/.bin/standard lib
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
  fi
  if [ -d ./spec ]; then
    echo "Linting package specs..."
    ./node_modules/.bin/standard spec
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
  fi
fi

echo "Running specs..."
# ATOM_PATH=./atom atom/Atom.app/Contents/Resources/app/apm/node_modules/.bin/apm test --path atom/Atom.app/Contents/Resources/app/atom.sh
apm test

exit

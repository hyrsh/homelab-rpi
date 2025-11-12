#!/bin/bash

# Path to where you mount your k8s secret to
tokenfile=$TOKEN_FILE

# Subpath to copy to your PVC mountpoint
subpath=$SUBPATH

if [ "$TOKEN_FILE" == "" ]; then
  echo -e "\e[33;1mNo token file found in \$TOKEN_FILE, continuing without!\e[0;0m"
fi
if [ "$SUBPATH" == "" ]; then
  echo -e "\e[33;1mNo subpath found in \$SUBPATH, continuing with \"docs\"!\e[0;0m"
  subpath="docs"
fi
if [ "$REPOSITORY_USER" == "" ]; then
  echo -e "\e[31;1mNo user found in \$REPOSITORY_USER!\e[0;0m"
  exit 2
fi
if [ "$REPOSITORY_NAME" == "" ]; then
  echo -e "\e[31;1mNo repository found in \$REPOSITORY_NAME!\e[0;0m"
  exit 3
fi

echo "-------"
echo "| Cloning repo: https://github.com/$REPOSITORY_USER/${REPOSITORY_NAME}.git"
echo "-------"

clone_dir="/tmp/repos"
data_dir="/data"

mkdir -p $clone_dir

cd $clone_dir

if [ "$TOKEN_FILE" == "" ]; then
  git clone https://github.com/$REPOSITORY_USER/${REPOSITORY_NAME}.git
else
  token=$(cat $tokenfile)
  git clone https://oauth2:$token@github.com/${REPOSITORY_USER}/${REPOSITORY_NAME}.git
fi

size_before=$(du -sb $data_dir | awk '{print $1}')
cp -ar ./$REPOSITORY_NAME/$SUBPATH/* $data_dir/
size_after=$(du -sb $data_dir | awk '{print $1}')

if [ $size_before != $size_after ]; then
  echo "[+] Size change from ${size_before}B to ${size_after}B"
fi

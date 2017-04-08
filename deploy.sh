#!/bin/bash

set -e
cd ~/blog/
#rm -rf public/*
hugo
cd public/
git add .
git commit -am "Site update at $(date)"
git push

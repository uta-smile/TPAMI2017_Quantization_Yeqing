#!/usr/bin/env sh
# This scripts downloads the multi-view data.

echo "Downloading..."

wget --no-check-certificate https://www.dropbox.com/s/e5htp1te16yadi1/cifar_split.mat
wget --no-check-certificate https://www.dropbox.com/s/525l7zf97u14jf5/mnist_split.mat

echo "Done."

#!/usr/bin/env sh
# This scripts downloads the multi-view data.

echo "Downloading..."

wget --no-check-certificate https://www.dropbox.com/s/fokovbdnb4ocawr/eightyMsubset_gnd.mat
wget --no-check-certificate https://www.dropbox.com/s/0ter3l8h5qlngih/eightyMsubset_hash_final.mat

echo "Done."

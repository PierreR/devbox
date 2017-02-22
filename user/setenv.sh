#! /usr/bin/env bash
mkdir -p build
ghc --make ./user/setenv.hs -O2 -threaded -outputdir=build/ -o build/build && build/build

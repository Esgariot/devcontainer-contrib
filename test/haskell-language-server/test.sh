#!/usr/bin/env bash

source dev-container-features-test-lib

check "'haskell-language-server-wrapper' executable is present in PATH and works" haskell-language-server-wrapper --version

mkdir hello_hs
cat <<- EOF > "hello_hs/hello.hs"
module Main where

main :: IO ()
main = putStrLn "hello"
EOF

check "'haskell-language-server-wrapper' can typecheck simple program" haskell-language-server-wrapper typecheck "hello_hs/hello.hs"

reportResults

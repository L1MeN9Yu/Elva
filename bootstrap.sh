#!/usr/bin/env bash

function main() {
  brew bundle
  pre-commit install
}

main

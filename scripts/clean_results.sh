#!/bin/bash

ROOT_DIR=".."
RESULTS_DIR="$ROOT_DIR/results"

echo "Cleaning Results Directory  ... "
rm -rf $RESULTS_DIR/*/*/Scenario*
rm -rf `pwd`/tmp


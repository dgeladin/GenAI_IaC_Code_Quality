#!/bin/bash

# Function to check a directory and add it to an array if not empty
check_and_add_directory() {
  local directory="$OUTPUT_DIR/$1"  # Local variable for the directory path

  if [ -d "$directory" ]; then
    if find "$directory" -mindepth 1 -maxdepth 1 | read -r line; then
      directories_to_process+=("$1")
    else
      echo "   Directory '$directory' is empty; not adding to process list."
    fi
  else
    echo "   Directory '$directory' does not exist."
  fi
}

ROOT_DIR=".."
DATA_DIR="$ROOT_DIR/data"
OUTPUT_DIR="$DATA_DIR/outputs"
RESULT_DIR="$ROOT_DIR/results/tflint"
SCENARIOS="Scenario01 Scenario02 Scenario03 Scenario04 Scenario05 Scenario06 Scenario07 Scenario08 Scenario09 Scenario10"

echo "Checking environment ... "

if [  -d "$OUTPUT_DIR" ]; then
    echo " OUTPUT_DIR: $OUTPUT_DIR is present"
else
    echo " OUTPUT_DIR: $OUTPUT_DIR is not present"
    exit 1;
fi

if [ -d "$RESULT_DIR" ]; then
    echo " RESULT_DIR: $RESULT_DIR is present"
else
    echo " OUTPUT_DIR: $OUTPUT_DIR is not present"
    exit 1;
fi

echo "Gathering list of GenAI models ... "
LLMS=`ls -1 $OUTPUT_DIR | grep -v .md`;
echo "$LLMS"

echo ""
echo "Checking subdirectories for content ... "  

for llm in $LLMS; do
   echo " Checking: $llm"
   for scenario in $SCENARIOS; do
      check_and_add_directory "${llm}/${scenario}"
   done
done

echo ""
echo "Counting the lines of code(LOC) on the following directories ... "
if [[ ${#directories_to_process[@]} -gt 0 ]]; then # Check if the array is not empty
  echo "Directories to process:"
  for dir in "${directories_to_process[@]}"; do

    total_lines=$(find "$OUTPUT_DIR/$dir" -type f -name "*.tf" -exec wc -l {} + | awk '{total += $1} END {print total}')
    echo " LOC: $dir : $total_lines : "
  done
else
  echo "No directories to process."
fi


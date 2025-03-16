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
RESULT_DIR="$ROOT_DIR/results/checkov"
SCRIPT_DIR=`pwd`
SCENARIOS="Scenario01 Scenario02 Scenario03 Scenario04 Scenario05 Scenario06 Scenario07 Scenario08 Scenario09 Scenario10"
DOWNLOAD_EXTERNAL="false"  # Set to "true" if you want to download external modules 

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
    echo " RESULT_DIR: $RESULT_DIR is not present"
    exit 1;
fi

if command -v checkov >/dev/null 2>&1; then
  echo " checkov is installed and in the PATH."
  checkov_path=$(command -v checkov)
  #echo "checkov path: $checkov_path"
else
  echo " checkov is not installed or not in the PATH."
  exit 1  # Failure
fi

echo "Gathering list of GenAI models to run checkov ... "
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

if [ $DOWNLOAD_EXTERNAL = "true" ]; then
   download_cmd=" --download-external-modules true --external-modules-download-path $SCRIPT_DIR/tmp"
   if [ ! -d "$SCRIPT_DIR/tmp" ]; then
      echo "Creating tmp directory for external module download"
      mkdir $SCRIPT_DIR/tmp
   fi
else
   download_cmd=" " 
fi

echo ""
echo "Running Checkov on the following directories ... "
if [[ ${#directories_to_process[@]} -gt 0 ]]; then # Check if the array is not empty
  echo "Directories to process:"
  for dir in "${directories_to_process[@]}"; do
    if [ ! -d "$RESULT_DIR/$dir" ]; then
	    echo "Creating dir: $dir"
	    mkdir -p $RESULT_DIR/$dir
    fi
    echo "  Processing: $dir"
    checkov -d $OUTPUT_DIR/$dir -o json $download_cmd --quiet --compact 2>&1> $RESULT_DIR/$dir/checkov_output.json
  done
else
  echo "No directories to process."
fi



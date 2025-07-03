#!/bin/bash

FILE="package.json"


handle_config(){
  # Update the lock file.
  echo "Updating packages..."
  npm i --package-lock-only
  echo "Finished."

  # Extract package information from node_modules and convert to desired YAML format
  yq eval '
    .packages |
    to_entries |
    map(select(.key | test("^node_modules/")) | 
      {
        "key": .key | sub("node_modules/"; "") | sub("\."; "_"),
        "value": {
          "name": (.key | sub("node_modules/"; "")),
          "version": .value.version,
          "url": .value.resolved,
          "installMode": "STORE_AND_INSTALL",
          "reloadExisting": false
        }
      }
    ) |
    from_entries
  ' "package-lock.json" -o=yaml > output.yaml

  echo "Transformation complete. Output written to output.yaml"
  return 0
}

# Check if yq is installed
if ! command -v yq &> /dev/null
then
    echo "yq could not be found, please install it to run this script."
    exit 1
fi

# Check if input folder is provided or one is present here
if [ -z "$1" ] && [ -e "$FILE" ]; then
    handle_config $FILE
    exit $?
elif [ -e "$1/$FILE" ]; then
    pushd "$1" > /dev/null || exit
    handle_config $FILE
    RES=$?
    popd > /dev/null || exit
    exit $RES
elif [ -z "$1" ]; then
    echo "Provide a valid path to package.json"
    exit 1
else
    echo "No package.json at $1/$FILE"
    exit 1
fi

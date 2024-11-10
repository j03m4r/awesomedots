#!/bin/bash

while IFS= read -r dependency; do
    dependency
done < "dependencies.txt"

echo "All dependencies have been set up."

#!/bin/zsh

# Check if the user provided an argument
if [ -z "$1" ]; then
  echo "Usage: up <number_of_directories>"
  return 1
fi

# Number of directories to go up
num=$1

# Generate the path to go up the given number of directories
cdpath=""
for ((i=0; i<num; i++)); do
  cdpath="../$cdpath"
done

echo "$cdpath"

# Change directory
cd "$cdpath" || { echo "Error: unable to change directory."; return 1; }

#!/usr/bin/env python3

import sys
from num2words import num2words

# Check if an argument is provided
if len(sys.argv) != 2:
    print("Usage: python script.py <number>")
    sys.exit(1)

# Get the argument and try to convert it to an integer
try:
    number = int(sys.argv[1])
except ValueError:
    print("Please provide a valid number.")
    sys.exit(1)

# Convert the number to words
number_in_words = num2words(number)

# Output the result
print(f"{number_in_words}")


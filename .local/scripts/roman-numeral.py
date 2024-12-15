#!/usr/bin/env python3

import sys

# Function to convert integer to Roman numerals
def int_to_roman(num):
    val = [
        1000, 900, 500, 400,
        100, 90, 50, 40,
        10, 9, 5, 4,
        1
    ]
    syb = [
        "M", "CM", "D", "CD",
        "C", "XC", "L", "XL",
        "X", "IX", "V", "IV",
        "I"
    ]
    
    roman_num = ''
    i = 0
    # Convert the number to Roman numerals
    while num > 0:
        for _ in range(num // val[i]):
            roman_num += syb[i]
            num -= val[i]
        i += 1
    return roman_num

# Check if an argument is provided
if len(sys.argv) != 2:
    print("Usage: python script.py <number>")
    sys.exit(1)

# Get the argument and convert it to an integer
try:
    number = int(sys.argv[1])
except ValueError:
    print("Please provide a valid number.")
    sys.exit(1)

# Convert the number to Roman numerals
roman_number = int_to_roman(number)

# Output the result
print(f"{roman_number}")


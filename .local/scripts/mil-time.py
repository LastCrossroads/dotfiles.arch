#!/bin/env python3

import sys
from num2words import num2words

def military_time_to_words(time_str):
    # Ensure the input is exactly 4 digits
    if len(time_str) != 4 or not time_str.isdigit():
        raise ValueError("Time must be in HHMM format (4 digits).")
    
    # Split the time string into hours and minutes
    hour = int(time_str[:2])
    minute = int(time_str[2:])
    
    # Convert hour and minute to words
    hour_in_words = num2words(hour)
    minute_in_words = num2words(minute)

    # Handle cases like "zero" minutes (e.g., "1400")
    if hour < 10 and minute < 10 and minute > 0:
        return f"zero {hour_in_words} hundred zero {minute_in_words}"
    if hour < 10 and minute == 0:
        return f"zero {hour_in_words} hundred"
    if minute == 0:
        return f"{hour_in_words} hundred"
    if hour < 10:
        return f"zero {hour_in_words} {minute_in_words}"
    else:
        if minute < 10 and minute > 0:
            return f"{hour_in_words} zero {minute_in_words}"
        return f"{hour_in_words} {minute_in_words}"

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 military_time_to_words.py HHMM")
        sys.exit(1)
    
    time_str = sys.argv[1]
    try:
        result = military_time_to_words(time_str)
        print(result)
    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)


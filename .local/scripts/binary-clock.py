#!/bin/env python3

import time

def int_to_binary_str(value, width):
    """Convert integer to binary string with leading zeros."""
    return format(value, f'0{width}b')

def binary_clock():
    while True:
        # Get current time
        current_time = time.gmtime()

        hours = current_time.tm_hour
        minutes = current_time.tm_min
        seconds = current_time.tm_sec

        # Convert time to binary representation
        binary_hours = int_to_binary_str(hours, 6)  # 6 bits for hours (0-23)
        binary_minutes = int_to_binary_str(minutes, 6)  # 6 bits for minutes (0-59)
        binary_seconds = int_to_binary_str(seconds, 6)  # 6 bits for seconds (0-59)

        # Print the binary clock
        print(f"{binary_hours}")
        print(f"{binary_minutes}")
        print(f"{binary_seconds}")

        # Wait for one second
        # time.sleep(1)
        exit()

if __name__ == "__main__":
    binary_clock()

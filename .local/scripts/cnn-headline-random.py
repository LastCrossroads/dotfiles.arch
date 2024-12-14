#!/bin/env python3

import requests
import xml.etree.ElementTree as ET
import random

def get_random_cnn_headline():
    # URL for CNN's Top Stories RSS feed
    rss_feed_url = "http://rss.cnn.com/rss/edition.rss"

    # Fetch the RSS feed
    response = requests.get(rss_feed_url)
    
    # Check if the request was successful
    if response.status_code != 200:
        raise Exception(f"Failed to fetch RSS feed: {response.status_code}")
    
    # Parse the XML response
    root = ET.fromstring(response.content)
    
    # Find all <item> elements, which contain the headlines
    items = root.findall("channel/item")
    
    # Extract all headlines
    headlines = [item.find("title").text.strip() for item in items]
    
    # Choose a random headline
    if headlines:
        random_headline = random.choice(headlines)
        return random_headline
    else:
        raise Exception("No headlines found in RSS feed")

if __name__ == "__main__":
    try:
        random_headline = get_random_cnn_headline()
        print(f"CNN: {random_headline}")
    except Exception as e:
        print(f"Error: {e}")


#!/bin/env python3

import requests
import xml.etree.ElementTree as ET

def get_latest_cnn_headline():
    # URL for CNN's Top Stories RSS feed
    rss_feed_url = "http://rss.cnn.com/rss/edition.rss"

    # Fetch the RSS feed
    response = requests.get(rss_feed_url)
    
    # Check if the request was successful
    if response.status_code != 200:
        raise Exception(f"Failed to fetch RSS feed: {response.status_code}")
    
    # Parse the XML response
    root = ET.fromstring(response.content)
    
    # Find the first <item> element, which contains the latest headline
    item = root.find("channel/item")
    if item is not None:
        # Extract and return the title of the first item
        title = item.find("title").text
        return title.strip()
    else:
        raise Exception("No headlines found in RSS feed")

if __name__ == "__main__":
    try:
        latest_headline = get_latest_cnn_headline()
        print(f"Latest CNN Headline: {latest_headline}")
    except Exception as e:
        print(f"Error: {e}")


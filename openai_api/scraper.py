import requests
from bs4 import BeautifulSoup
import json
from lxml import etree

from lxml import html

def scrape_coffee_shops(url):
    # Fetch the page content
    # Send an HTTP request to the website and retrieve the HTML content
    response = requests.get(url)
    response.encoding = 'utf-8'

    # Parse the HTML content using lxml
    tree = html.fromstring(response.content)
    # Locate coffee shop listings

    etree.strip_elements(tree, 'script')

    div_element = tree.xpath('//div[@id="BoardAndMap__block_49"]')

    if div_element:
        a_element = div_element[0].xpath('.//a[contains(@class, "color-gray-900")]')
        if a_element:
            # Get the text value of the a element
            text_value = a_element[0].text.strip()
            print(f"Text value: {text_value}")
        else:
            print("Element with class 'color-gray-900' not found within the div")
    else:
        print("Element with id 'BoardAndMap__block_49' not found")
    


if __name__ == "__main__":
    url = "https://wanderlog.com/list/geoCategory/293946/best-coffee-shops-and-best-cafes-in-valparaiso-region"
    shops = scrape_coffee_shops(url)

from dotenv import load_dotenv
import os
import requests
import json

load_dotenv()

API_KEY = os.getenv("GOOGLE_MAPS_API_KEY") 
LAT = os.getenv("INITIAL_LAT")
LNG = os.getenv("INITIAL_LNG")
RADIUS =  os.getenv("RADIUS")
OUTPUT_FILE = "cafes.json"


def get_cafes(api_key, lat, lng, radius):
    nearby_search_url = (
        f"https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        f"?location={lat},{lng}&radius={radius}&type=cafe&key={api_key}"
    )
    
    cafes = []
    next_page_token = None

    while True:
        if next_page_token:
            response = requests.get(f"{nearby_search_url}&pagetoken={next_page_token}")
        else:
            response = requests.get(nearby_search_url)

        if response.status_code != 200:
            print("Error with Nearby Search API:", response.text)
            break

        data = response.json()
        places = data.get("results", [])
        
        for place in places:
            name = place.get("name", "Unknown")
            place_id = place.get("place_id")
            
            address = "N/A"
            website = "N/A"
            if place_id:
                details_url = (
                    f"https://maps.googleapis.com/maps/api/place/details/json"
                    f"?place_id={place_id}&fields=name,website,formatted_address&key={api_key}"
                )
                details_response = requests.get(details_url)
                if details_response.status_code == 200:
                    details = details_response.json().get("result", {})
                    address = details.get("formatted_address", "N/A")
                    website = details.get("website", "N/A")
            
            online = True if website != "N/A" else False
            cafes.append({"title": name, "address": address, "online": online, "link": website})
        
        next_page_token = data.get("next_page_token")
        if not next_page_token:
            break
        import time
        time.sleep(2)

    return cafes


def save_to_json(data, filename):
    with open(filename, "w") as file:
        json.dump(data, file, indent=4)
    print(f"Data saved to {filename}")


cafes = get_cafes(API_KEY, LAT, LNG, RADIUS)
save_to_json(cafes, OUTPUT_FILE)
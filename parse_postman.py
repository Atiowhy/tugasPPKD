import json
import sys

def extract_endpoints(item_list, prefix=""):
    endpoints = []
    for item in item_list:
        if "item" in item:
            # It's a folder
            folder_name = item.get("name", "Unknown Folder")
            endpoints.extend(extract_endpoints(item["item"], prefix + folder_name + " / "))
        elif "request" in item:
            # It's a request
            req = item["request"]
            method = req.get("method", "UNKNOWN")
            url = ""
            if isinstance(req.get("url"), dict):
                url = req["url"].get("raw", "")
            elif isinstance(req.get("url"), str):
                url = req["url"]
            name = item.get("name", "Unnamed Request")
            endpoints.append(f"{prefix}{name} [{method}] {url}")
    return endpoints

if __name__ == "__main__":
    file_path = "D:/AppPro/tugas15flutter/ABSENSI PPKD B3.postman_collection.json"
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        
        print(f"Collection Name: {data.get('info', {}).get('name', 'Unknown')}")
        endpoints = extract_endpoints(data.get("item", []))
        for ep in endpoints:
            print(ep)
    except Exception as e:
        print(f"Error: {e}")

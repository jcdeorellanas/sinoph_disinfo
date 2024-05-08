"""
Packages required for this code
"""
#pip install --upgrade google-api-python-client
#pip install pysentimiento
#pip install --upgrade pandas
#pip install --upgrade matplotlib
# -----------------------------------------------------------------------------------------------

import os
import requests
import re
import json
import time # to call the .sleep() method to include a pause that respects potential respect API limits
import pandas as pd
import matplotlib.pyplot as plt

from datetime import datetime
from googleapiclient.discovery import build
from youtube_api import YouTubeDataAPI
from youtube_api import parsers as P

# -------------------------------------------------------------------------------------------------
YT_KEY = os.environ.get('YOUTUBE_API_KEY') # Key is saved in ~/.zshrc
api_key = YT_KEY
yt = YouTubeDataAPI(YT_KEY)

# -------------------------------------------------------------------------------------------------
"""
Create ISO date object to save into json file
"""
class DateTimeEncoder(json.JSONEncoder):
    """Custom encoder for datetime objects."""
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.isoformat()  # Convert datetime to ISO format string
        # Let the base class default method raise the TypeError
        return super().default(obj)

# --------------------------------------------------------------------------------------------------
"""
Function to get the ID of a YouTube channel using the channel's display_name
"""
def find_channel_id_by_display_name(display_name, api_key):
    # Define the endpoint and parameters for the request
    search_url = 'https://www.googleapis.com/youtube/v3/search'
    params = {
        'part': 'snippet',
        'q': display_name,
        'type': 'channel',
        'key': api_key
    }
    
    # Make the GET request
    response = requests.get(search_url, params=params)
    
    # Check if the request was successful
    if response.status_code == 200:
        # Parse the response
        search_results = response.json()
        
        # Loop through the search results and find the matching channel
        for item in search_results.get('items', []):
            # Check if the snippet's channel title closely matches the search query (display name)
            if item['snippet']['channelTitle'].lower() == display_name.lower():
                return item['snippet']['channelId']
        
        # If exact match is not found, return a message
        return "No exact match found for the display name."
    else:
        # If the request was not successful, return an error message with the status code
        return f"Failed to retrieve data: HTTP Status Code {response.status_code}"

# ---------------------------------------------------------------------------------------------
'''
Function to get the ID of a YouTube channel using the Channel's username
'''
def get_channel_id(channel_username, api_key):
    try:
        # Make a GET request to the YouTube Data API's channels.list method
        response = requests.get(
            'https://www.googleapis.com/youtube/v3/channels',
            params={
                'part': 'id',
                'forUsername': channel_username,
                'key': api_key
            }
        )
        # Check if the request was successful
        if response.status_code == 200: # status code of 200 indicates successful request (API endpoint was reached without any errors)
            response_json = response.json() # parse the JSON content returned by the API into a Python dictionary
            items = response_json.get('items', []) # retrieves 'items' list from JSON object
            
            if items:
                # Assuming the first item is the correct channel
                channel_id = items[0]['id']
                return channel_id
            else:
                return "No channel found for the given username."
        else:
            return "Failed to retrieve data: HTTP Status Code {}".format(response.status_code)
    except Exception as e:
        # Handle potential exceptions, such as a network error
        return "An error occurred: {}".format(e)

# ---------------------------------------------------------------------------------------------------------------
'''
Objects to use in the `find_channel_id...` and `get_channel_id` functions
'''
chan_names_list = ['willaxtv', 'PBO'] # List of channel usernames
display_name = 'PBO'  # The display name of the channel I am searching for

# ---------------------------------------------------------------------------------------------------------------
"""
Search for YouTube channel IDs using the functions and objects defined, 
and get the chanel's playlists using the `get_playlists()` function from the 
`youtube_api`
""" 
# Dictionary to store channel usernames and their IDs
channel_ids = {}

# Loop through each channel username in the list
for channel_username in chan_names_list:
    # Call get_channel_id for each username
    channel_id = get_channel_id(channel_username, api_key)
    if channel_id == "No channel found for the given username.":
        # Using the find_channel_id_by_display_name
        channel_id = find_channel_id_by_display_name(channel_username, api_key) 
    # Store the result in the dictionary
    channel_ids[channel_username] = channel_id

# Debug: Print resulting dictionary
# print(channel_ids)
 
filename = 'covid_disinfo_peru_yt_playlists.json'
# Load existing data if the file exists
if os.path.exists(filename):
    with open(filename, 'r') as file:
        data = json.load(file)
else:
    data = {}

# Loop through each channel ID to get and process playlists
for channel_username, channel_id in channel_ids.items():
    '''print(f"Retrieving playlists for channel: {channel_username} with ID {channel_id}")'''

    # Get the playlists for the channel
    ch_playlists = yt.get_playlists(channel_id, next_page_token=False, 
                                    parser=P.parse_playlist_metadata, 
                                    part=['id', 'snippet', 'contentDetails'])
    
    # Compile a regular expression pattern for the keywords, making it case-insensitive
    pattern = re.compile(r'barba|rey|butters|leiva|beto|thorndike|vivo', re.IGNORECASE)

    # List to store matched playlists
    matched_playlists = []

    # Iterate over the playlists and search for the pattern in their names
    for playlist in ch_playlists:
        if pattern.search(playlist['playlist_name']):
            matched_playlists.append(playlist)
    # Output the matched playlists
    print(f"Matched playlists for {channel_username}:")
    
    for match in matched_playlists:
        print(match['playlist_name'])
        #print(match)
    
    # Convert datetime objects in matched_playlists to strings
    for playlist in matched_playlists:
        # Assuming 'collection_date' is the datetime object to convert
        if 'collection_date' in playlist and isinstance(playlist['collection_date'], datetime):
            playlist['collection_date'] = playlist['collection_date'].isoformat()
       
    # Updates data with the new matched_playlists for each channel_username
    data[channel_username] = matched_playlists

# Write the updated data back to the JSON file
with open(filename, 'w') as file:
    json.dump(data, file, indent=4)

# ---------------------------------------------------------------------------------------------------
"""
Iterate over playlist json file to get details needed to retrieve videos with 
`get_videos_from_playlist_id()` function and save them in independent files

open jason dictionary
for loop to iterate in the playlists dictionary
get playlist_id and _name
clean playlist_name to use it in file name. 
Regex and shorting name yt function to get videos (and their metadata) from playlist store the data in a json file
"""
# Open the playlists file
filename = 'covid_disinfo_peru_yt_playlists.json'

# Load existing data if the file exists
if os.path.exists(filename):
    with open(filename, 'r') as file:
        channels_data = json.load(file)
else:
    raise FileNotFoundError("The file: '" + filename + "' doesn't exist. Check its name or path.")

for channel_name, playlists in channels_data.items():
    #print(f"Channel: {channel_name}")
    for playlist in playlists:
        playlist_id = playlist['playlist_id']
        playlist_name = playlist['playlist_name']
        print(f"Processing playlist: {playlist_name} with ID: {playlist_id}")
        
        # Sanitize the playlist name to create a valid filename. Removes characters not allowed in filenames and limits the length
        safe_playlist_name = re.sub(r'[^\w\s-]', '', playlist_name).strip()[:20].replace(' ', '_')
        fetched_vids = f"{safe_playlist_name}_2020-21_videos.json"

         # Call the function to get videos from this playlist ID
        video_metadata = yt.get_videos_from_playlist_id(playlist_id=playlist_id, 
                                                        next_page_token=None, 
                                                        parser=P.parse_video_url, 
                                                        part=['snippet'], 
                                                        max_results=200000)
        # Save the fetched video metadata to a file named after the playlist
        with open(fetched_vids, 'w') as file:
            json.dump(video_metadata, file, cls=DateTimeEncoder, indent=4)
        
        print(f"Data saved to {fetched_vids}")
        print(f"Number of videos fetched: {len(video_metadata)}")
        
        time.sleep(5)  # Pause to respect API limits

# --------------------------------------------------------------------------------------------------
"""
Retrieve the video ids from the data in files filtering by date, get their metadata with the 
`get_video_metadata()` function, and to save them in a new file.
"""
# assign directory
directory = 'data/willax_pbo_youtube_vids'
   
# Initialize an empty list to store all video IDs
all_videos_ids = []

# Iterate over files in the directory to collect video IDs
for filename in os.listdir(directory):
    filepath = os.path.join(directory, filename)  # Get the full path to the file
    
    # Check if file is a JSON file
    if os.path.isfile(filepath) and filepath.endswith('.json'):
        with open(filepath, 'r') as file:
            data = json.load(file)
            
            # Date range
            start_date = datetime(2020, 10, 1).timestamp()
            end_date = datetime(2021, 12, 31).timestamp()
            
            # Filter videos within the date range and collect their video_ids
            for video in data:
                publish_date = video['publish_date']
                if start_date <= publish_date <= end_date:
                    all_videos_ids.append(video['video_id'])
#print(f"Total videos to process: {len(all_videos_ids)}")

# Process each video ID
# Initialize matched_metadata outside the loop
matched_metadata = []

for video_id in all_videos_ids:
    print(f"Retrieving metadata for video_ID: {video_id}")
    vid_metadata = yt.get_video_metadata(video_id=video_id, 
                                         parser=P.parse_video_metadata, 
                                         part=['statistics', 'snippet'])
    matched_metadata.append(vid_metadata)
    time.sleep(5)

# Choose an appropriate filename for saving the data
video_dets_file = "all_videos_filtered.json"
vid_file_path = os.path.join(directory, video_dets_file)

with open(vid_file_path, 'w') as file:
    json.dump(matched_metadata, file, cls=DateTimeEncoder, indent=4)
# print(f"Data saved to {vid_file_path}")
# print(f"Number of videos saved: {len(matched_metadata)}")

# ----------------------------------------------------------------------------------------
"""
Compile videos filtered by term and save them in new file
"""
filename = "all_videos_filtered.json"
filepath = os.path.join(directory, filename)  # Get the full path to the file

# Define the search terms
terms = ['Sinopharm', 'Sinovac', 'vacuna china', 'eficacia', 'vacuna', 'bustamante']
# Compile a regex pattern for case-insensitive search of these terms
pattern = re.compile(r'\b(?:' + '|'.join(re.escape(term) for term in terms) + 
                     r')\b', re.IGNORECASE)

matching_videos_count = 0

filtrd_lst = []

with open(filepath, 'r') as file:
    videos = json.load(file)
    #first_element = videos[0]
    #print(type(first_element), first_element)
    for video in videos:
        # Search in both the video title and description
        try:
            if type(video) == dict and (pattern.search(video['video_title']) 
                                        or pattern.search(video['video_description'])):
                matching_videos_count += 1
                #print("Appending ", video['video_title'], "to filtrd_lst")
                filtrd_lst.append(video)

        except Exception as e:
            print(video)
print(f"Number of matching videos: {matching_videos_count}")
print(len(filtrd_lst))

extracted_videos = "sinoph_pbo_willax_disinfo.json"
vid_file_path = os.path.join(directory, extracted_videos)

with open(vid_file_path, 'w') as file:
    json.dump(filtrd_lst, file, cls=DateTimeEncoder, indent=4)

print(f"Data saved to {vid_file_path}")
print(f"Number of videos saved: {len(filtrd_lst)}")

# -------------------------------------------------------------------------------------
"""Get comments from videos beteen March and September 2021 using the `get_video_comments()` 
function and to create a json file to store them"""

directory = 'VIDEO/DIRECTORY'

video_file = "sinoph_pbo_willax_disinfo.json"
vid_file_path = os.path.join(directory, video_file)

with open(vid_file_path, 'r') as file:
    print(f"Opening {vid_file_path}")
    videos_data = json.load(file)

df_willax_sinoph = pd.DataFrame(videos_data)
df_willax_sinoph.tail(5)

df_willax_sinoph.info

# Convert UNIX timestamp to human-readable date (the unit='s' specifies that the timestamp is in seconds)
df_willax_sinoph["video_publish_date"] = pd.to_datetime(df_willax_sinoph["video_publish_date"], unit='s', origin='unix')
df_willax_sinoph["video_publish_date"] = df_willax_sinoph["video_publish_date"].dt.date
df_willax_sinoph = df_willax_sinoph.sort_values(by="video_publish_date", ascending=True)
#print(df_willax_sinoph)

willax_sinoph_sub = df_willax_sinoph[['video_publish_date', 'video_id', 'video_title', 
                                      'video_description', 'video_view_count', 'video_comment_count', 
                                      'channel_title', 'channel_id']].rename(columns = {
        'video_publish_date': 'publish_date',
        'video_title': 'title', 
        'video_description': 'description',
        'video_view_count': 'views', 
        'video_comment_count': 'comment_count',
        'channel_title': 'channel' 
    }
)
willax_sinoph_sub

wil_sino_mar_sep_21 = willax_sinoph_sub[
    (willax_sinoph_sub["publish_date"] >= datetime.strptime('2021-03-01', '%Y-%m-%d').date()) &
    (willax_sinoph_sub["publish_date"] <= datetime.strptime('2021-09-30', '%Y-%m-%d').date())
]

wil_sino_mar_sep_21.shape

video_list = ['9K9Vpk2N38M', 'FmHqf_7sgnE', 'FmHqf_7sgnE', 'mLhonH1bDOA', 'N8TCILfoxqk', '61MuoV0b_wc', 'P_CqzxTz8qc', 
 'L7zdcppc2Ro', 'PagOb0eOyOQ', 'YBuaoRv3iIg', 'Uq0sf0pvo60', 'Yiaxey-NaVQ', 'zDFmWHAVPdE', 'g1rOO2hH9Nw', 
 'SrybIYyjXS0', 'nFMhTNYVmyU',  '98_C_oIgrok', 'jOs8UNJKsFU', '5biabFQuzvo', '2OQtHMsi6G4', 'ER8T0SRG-vQ']

# Dictionary to store the comments for each video
video_comments_dict = {}

for video_id in video_list:
    try:
        vid_comments = yt.get_video_comments(video_id=video_id, parser=P.parse_comment_metadata, get_replies=True,
                                             max_results=None, next_page_token=False,
                                             part=['snippet'])
        # Assuming yt.get_video_comments raises an exception on failure and does not return a response object
        # Store the comments in a dictionary using the video_id as the key
        video_comments_dict[video_id] = vid_comments
    except Exception as e:
        # Handle potential exceptions, such as a network error or API error
        print("An error occurred for video ID {}: {}".format(video_id, e))
    time.sleep(20)  # Delay of 20 seconds between requests

# Check dictionary
video_comments_dict

comments_file = "wil_pbo_sinoph_comments.json"
file_path = os.path.join(directory, comments_file)

with open(file_path, 'w') as file:
    json.dump(video_comments_dict, file, cls=DateTimeEncoder, indent=4)

print(f"Data saved to {file_path}")


# Data frame with comments data for video of March 5, 2021.
df_prsd_comments = pd.DataFrame(video_comments_dict['9K9Vpk2N38M'])
df_prsd_comments
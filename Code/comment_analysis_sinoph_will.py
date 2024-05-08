"""
Required packages
"""
#!pip install pysentimiento
#!pip install transformers
# ------------------------------------------------------------------------------------------------
import pandas as pd
import os
import re
import json
import time # to call the .sleep() method to include a pause that respects potential respect API limits
import matplotlib.pyplot as plt
import transformers

from pysentimiento import create_analyzer
from pysentimiento.preprocessing import preprocess_tweet

from datetime import datetime

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
    
# -------------------------------------------------------------------------------------------------
"""
Initialize transformers and pysentimiento analyzers for sentiment, hate speech, and emotion analysis.
*** Note, specify `es` for Spanish language ***
"""

transformers.logging.set_verbosity(transformers.logging.ERROR)

sentiment_analyzer = create_analyzer(task="sentiment", lang="es")

hate_speech_analyzer = create_analyzer(task="hate_speech", lang="es")

emotion_analyzer = create_analyzer(task="emotion", lang="es")

# -------------------------------------------------------------------------------------------------
"""
Testing 3 comments
"""
comment = "CAGASTI A LA CARCEL POR GENOCIDIO,  EL PODER JUDICIAL DEBE PRONUNCIARSE AL RESPECTO, LOS FISCALES DE OFICIO DEBEN PROCESARLO POR INEPTO, la vacuna Rusa era gratis, y no podia coimear, por eso prefirio comprar los placebos Chinos,  porque ahi si cutrea de lo lindo,  tipo corrupto, es para arrastrarlo de las barbas  por palacio de gobierno hasta echarlo a las calles como el despojo humano que es."

# pysentimiento pre-processing function
preprocess_tweet(comment)
print(sentiment_analyzer.predict(comment))
print(hate_speech_analyzer.predict(comment))
print(emotion_analyzer.predict(comment))

comment_2 = "SIN DUDA ES EL MEJOR NOTICIERO"
# pysentimiento pre-processing function
preprocess_tweet(comment_2)
print(sentiment_analyzer.predict(comment_2))
print(hate_speech_analyzer.predict(comment_2))
print(emotion_analyzer.predict(comment_2))

comment_3 = "SAGASTI Y EL MITOMANO DE VIZCARRA SON GENOSIDAS DEBEN SER FUSILADOS EN PUBLICO CUANTAS FAMILIAS LLORAN SUS MUERTOS POR QUE SE CIERRAN CON LAS VACUNAS CHINAS QUE NO SIRVE NI DESINFECTANTE."
# pysentimiento pre-processing function
preprocess_tweet(comment_3)
print(sentiment_analyzer.predict(comment_3))
print(hate_speech_analyzer.predict(comment_3))
print(emotion_analyzer.predict(comment_3))

# -------------------------------------------------------------------------------------------------
'''
Code to process comments

# Pseudocode 
1. check the structure of json file to determine course of action
1.1 Each dictionary contains the comments to a video
2. open the json file in read mode
2.1 use pandas to see the info
3. iterate over it to get the information. 
4. create a new dictionary per each video with video_id, user_id, other relevant info decided in step 1.1, and results of the sentiment, emotion and hate analysis
5. Manually iterate over the comment content to see if they respond to the misinfo, and how other users reacted to said response.
'''
# Define path to file containing video comments
filepath = "THE_FILE.json"
# Open file and load data
with open(filepath, 'r') as file:
    video_comments = json.load(file)

# Check json file keys
video_comments.keys()

# -------------------------------------------------------------------------------------------------
# Function to perform analysis
def analyze_comment(comment_text):
        
    processed_text = preprocess_tweet(comment_text)
    sentiment_result = sentiment_analyzer.predict(processed_text)
    hate_speech_result = hate_speech_analyzer.predict(processed_text)
    emotion_result = emotion_analyzer.predict(processed_text)

    # Return a dictionary containing the results
    return {
        'sentiment': sentiment_result,
        'hate_speech': hate_speech_result,
        'emotion': emotion_result
    }

# ------------------------------------------------------------------------------------------------
# Dictionary to store analyzed comments by video ID
anlzd_vcoms_dict = {}

# Iterate through each video ID and its corresponding comments list
for video_id, comments in video_comments.items():
    # List to hold the analyzed comments for the current video
    analyzed_comments = []
    
    # Iterate through each comment dictionary in the comments list
    for comment in comments:
        # Apply your sentiment and emotion analysis on the comment text
        analysis_result = analyze_comment(comment['text'])
        # Add the analysis result to the list of analyzed comments for this video
        analyzed_comments.append(analysis_result)

    # Store the analyzed comments in the dictionary with the video_id as key
    anlzd_vcoms_dict[video_id] = analyzed_comments

# Check dictionary
type(anlzd_vcoms_dict)
len(anlzd_vcoms_dict)
anlzd_vcoms_dict.keys()
anlzd_vcoms_dict.values()

# ------------------------------------------------------------------------------------------------
# Saving dictionary containing analyzed comments
anlzd_vcoms_file = "PATH_TO_FILE2.json"

with open(anlzd_vcoms_file, 'w') as file:
    json.dump(anlzd_vcoms_dict, file, cls=DateTimeEncoder, indent=4)

print(f"Data saved to {anlzd_vcoms_file}")
# ------------------------------------------------------------------------------------------------






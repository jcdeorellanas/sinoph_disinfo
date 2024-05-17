# sinoph_disinfo
This repository contains the code, data, and results from a preliminary study on a disinformation campaign launched in 2021 against the Sinopharm vaccine campaign in Peru. 

To reproduce the project, follow the instructions below:
A. Get the data: To access the APIs, compile data, preprocess it, and put it into the formats needed for analysys

1. Access the 'Code' directory
2. Open the 'youtube_api_sinoph.py'
2.1 Replace 'YOUTUBE_API_KEY' variable with your own API key in the YT_KEY = os.environ.get('YOUTUBE_API_KEY') function
2.2 Run the code
3. Open the 'gtrends_sinopharm.py' to use the Google trends API, repeat the searches and saved them 
3.1 Run the code and replace the 'filepath' variables with the addresses where the files should be saved
4. Open the 'comment_analysis_sinoph_will.py' to perform sentiment, emotion, and hate-speech analysis with `pysentimiento` package
4.1 Run the code to preprocess the text using pysentimiento's own function, perform sentiment, emotion, and hate speech analysis *This code is still partial. It needs to be corrected so the data can be saved in a JSON file.*
   
B. Analyse the data
6. Open the 'sinoph_misinfo_gtrends.R' to access the google trends data, preprocess, and plot it for visualization, analysis, interpretation, and analysis
7. Open the 'sinoph_pbo_willax_analysis.R' to access the data regarding the videos, preprocess, and plot it for visualization, analysis, interpretation, and analysis.

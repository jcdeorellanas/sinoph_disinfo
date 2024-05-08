
'''Packages specific for this assignment'''
#pip install pytrends
#pip install tables

import pandas as pd
import os
import re
import json

from datetime import datetime

from pytrends.request import TrendReq
pytrend = TrendReq()

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

# ---------------------------------------------------------------------------------------
"""
Create paths to save and access gtrends files
"""
directory = 'data/google_trends'
# ---------------------------------------------------------------------------------------
"""
Build payload for the keywords1 list. Google Trends only admits 5
"""
keywords1 = ['vacuna Sinopharm', 'sinopharm', 'sinopharm vacuna', 'vacuna covid']
pytrend.build_payload(kw_list=keywords1, timeframe='2020-10-01 2022-06-30', geo='PE')
interest_over_time_df1 = pytrend.interest_over_time()
# print(interest_over_time_df1)

# Search for related queries for keywords1
related_queries_1 = pytrend.related_queries()
print(related_queries_1)

# --------------------------------------------------------------------------------------
"""
Build payload for the keywords2 list. Google Trends only admits 5
"""
keywords2 = ['sinopharm efectividad', 'vacuna sinopharm efectividad', 
             'sinopharm vacuna efectividad', 'efictividad sinopharm', 'vacuna covid']
pytrend.build_payload(kw_list=keywords2, timeframe='2020-10-01 2022-06-30', geo='PE')
interest_over_time_df2 = pytrend.interest_over_time()
# print(interest_over_time_df2)

# Search for related queries for keywords2
related_queries_2 = pytrend.related_queries()
print(related_queries_2)

# --------------------------------------------------------------------------------------
"""
Build payload for the keywords3 list. Google Trends only admits 5
"""
keywords3 = ['vacuna pfizer', 'pfizer', 'pfizer vacuna', 'vacuna covid' ]
pytrend.build_payload(kw_list=keywords3, timeframe='2020-10-01 2022-06-30', geo='PE')
interest_over_time_df3 = pytrend.interest_over_time()
# print(interest_over_time_df3)

# Search for related queries for keywords3
related_queries_df3 = pytrend.related_queries()
print(related_queries_df3)

# --------------------------------------------------------------------------------------
"""
Build payload for the keywords4 list. Google Trends only admits 5
"""
keywords4 = ['pfizer efectividad', 'efectividad pfizer', 'vacuna pfizer efectividad', 'pfizer efectividad vacuna', 'vacuna covid']
pytrend.build_payload(kw_list=keywords4, timeframe='2020-10-01 2022-06-30', geo='PE')
interest_over_time_df4 = pytrend.interest_over_time()
print(interest_over_time_df4)

# Search for related queries for keywords4
related_queries_4 = pytrend.related_queries()
print(related_queries_4)

# --------------------------------------------------------------------------------------
"""
Build payload for the keywords5 list. Google Trends only admits 5
"""
keywords5 = ["covid vacuna", "AstraZeneca","AstraZeneca efectividad", 'vacuna covid']
pytrend.build_payload(kw_list=keywords5, timeframe='2020-10-01 2022-06-30', geo='PE')
interest_over_time_df5 = pytrend.interest_over_time()
# print(interest_over_time_df5)

# Search for related queries for keywords5
related_queries_5 = pytrend.related_queries()
print(related_queries_5)

# --------------------------------------------------------------------------------------

# Save the queries
'''filename1 = "interest_over_time_df1.csv"
filepath1 = os.path.join(directory, filename1)  # Get the full path to the file
interest_over_time_df1.to_csv(filepath1)

filename2 = "interest_over_time_df2.csv"
filepath2 = os.path.join(directory, filename2)  # Get the full path to the file
interest_over_time_df2.to_csv(filepath2)

filename3 = "interest_over_time_df3.csv"
filepath3 = os.path.join(directory, filename3)  # Get the full path to the file
interest_over_time_df3.to_csv(filepath3)

filename4 = "interest_over_time_df4.csv"
filepath4 = os.path.join(directory, filename4)  # Get the full path to the file
interest_over_time_df4.to_csv(filepath4)

filename5 = "interest_over_time_df5.csv"
filepath5 = os.path.join(directory, filename5)  # Get the full path to the file
interest_over_time_df5.to_csv(filepath5)'''

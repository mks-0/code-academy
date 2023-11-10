import gspread 
from streamlit import line_chart
from streamlit.web.cli import main
import pandas as pd
import numpy as np
import os

def get_data():
    auth = os.environ.get('service_account')
    gc = gspread.service_account(auth)
    sh = gc.open('DataPipelines')
    worksheet = sh.worksheet('Sheet1')
    df = pd.DataFrame(columns=['Date', 'Close'])
    df['Date'] = worksheet.col_values(1)[1:]
    df['Close'] = worksheet.col_values(2)[1:]
    df['Date'] = pd.to_datetime(df['Date'])
    return df

print(get_data())

line_chart(get_data(), x='Date', y='Close')


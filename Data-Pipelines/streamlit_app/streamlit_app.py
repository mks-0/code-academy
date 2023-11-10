import gspread
import streamlit as st 
from streamlit import line_chart
from streamlit.web.cli import main
from streamlit_gsheets import GSheetsConnection
import pandas as pd
import numpy as np
import os


def get_data():
    conn = st.connection("gsheets", type=GSheetsConnection)
    gc = gspread.service_account(conn.read())
    sh = gc.open('DataPipelines')
    worksheet = sh.worksheet('Sheet1')
    df = pd.DataFrame(columns=['Date', 'Close'])
    df['Date'] = worksheet.col_values(1)[1:]
    df['Close'] = worksheet.col_values(2)[1:]
    df['Date'] = pd.to_datetime(df['Date'])
    return df

print(get_data())

line_chart(get_data(), x='Date', y='Close')


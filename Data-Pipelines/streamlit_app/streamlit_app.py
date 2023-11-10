import gspread
import streamlit as st 
from streamlit.web.cli import main
from streamlit_gsheets import GSheetsConnection
import pandas as pd
import numpy as np


def get_data():
    conn = st.connection("gsheets", type=GSheetsConnection)
    # print(conn.read())
    # gc = gspread.service_account(conn.read())
    # sh = gc.open('DataPipelines')
    # worksheet = sh.worksheet('Sheet1')
    # df = pd.DataFrame(columns=['Date', 'Close'])
    # df['Date'] = worksheet.col_values(1)[1:]
    # df['Close'] = worksheet.col_values(2)[1:]
    # df['Date'] = pd.to_datetime(df['Date'])
    url = "https://docs.google.com/spreadsheets/d/11q16a6xO9Q6u22osRzyQqEIr4ha5bJwNaCktScBlj1A/edit#gid=0"
    data = conn.read(spreadsheet=url, usecols=[0, 1])
    
    return data

print(get_data())

st.line_chart(get_data(), x='date', y='close')


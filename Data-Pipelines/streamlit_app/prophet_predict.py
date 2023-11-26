import prophet
import os
os.environ['CMDSTAN'] = "C:/Users/milan/anaconda3/envs/p38/Library/bin/cmdstan"

from prophet import Prophet
m = prophet.Prophet()

import pandas as pd
df = pd.read_csv('https://raw.githubusercontent.com/facebook/prophet/main/examples/example_wp_log_peyton_manning.csv')
print(df.head())
m = Prophet()
m.fit(df)
future = m.make_future_dataframe(periods=365)
print(future.tail())
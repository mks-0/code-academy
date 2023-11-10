import urllib3
import json
def get_data():
    http = urllib3.PoolManager()
    url = "https://cloud.iexapis.com/stable/stock/tsla/previous?token=pk_df4b98350c904cc09150100ad30c9799"
    resp = http.request("GET", url)
    values = json.loads(resp.data)
    # d = [(x['date'], x['close']) for x in values]
    # print(d)
    return values
get_data()

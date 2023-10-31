import pandas as pd

def get_cost_price(data):
    '''Get the Cost and Sell Price of the Product from Order's Sales, Profit and Quantity'''
    data.loc[:, 'Cost'] = round((data['Sales'] - data['Profit'])/data['Quantity'], 4)
    data.loc[:, 'Sell Price'] = round(data['Sales']/((1 - data['Discount'])*data['Quantity']), 4)
    
    return data

def gen_product_id(data):
    '''Generating unique Product IDs based on it's name and price'''
    for category in data['Category'].unique():
        for subcategory in data[data['Category'] == category]['Sub-Category'].unique():
            products_grouped = data[(data['Category'] == category) & (data['Sub-Category'] == subcategory)].groupby(['Product Name', 'Cost'])
            for i, (key, item) in enumerate(products_grouped):
                group = products_grouped.get_group(key)
                cat = group['Category'].unique()[0][:3].upper()
                sub = group['Sub-Category'].unique()[0][:3].upper()
                item['id'] = cat + '-' + sub + '-' + str(i).zfill(8)
                for index, row in item['id'].items():
                    data.loc[index, 'id'] = row
    return data

def filter_outliers(data):
    '''Filter ouliers for Series based on +- 1.5 Interquartile range'''
    q1 = data.quantile(0.25)
    q3 = data.quantile(0.75)
    iqr = 1.5 * (q3 - q1)
    return data[(data > (q1 - iqr)) & (data < (q3 + iqr))]

def get_outliers(data):
    '''Get the ouliers of the dataframe, based on all the columns'''
    filtered = pd.DataFrame()
    for col in data.columns[1:]:
        filtered[col] = filter_outliers(data[col])
    return data.iloc[data.iloc[:, 1].index.difference(filtered.iloc[:, 1].index)]

def cluster_outliers(outliers, cluster_data):
    '''Join the outliers back to the dataframe and assign a new cluster to them'''
    outliers = outliers.copy()
    new_cluster = cluster_data['Cluster ID'].max() + 1
    outliers.loc[:, 'Cluster ID'] = new_cluster
    return pd.concat([cluster_data, outliers], axis=0)
    
# class Outliers:

#     def __init__(self, data):
#         self.data = data

#     def filter_outliers(self, column):
#         q1 = column.quantile(0.25)
#         q3 = column.quantile(0.75)
#         iqr = 1.5 * (q3 - q1)
#         return column[(column > (q1 - iqr)) & (column < (q3 + iqr))]

#     def get_outliers(self):
#         filtered = pd.DataFrame()
#         for col in self.data.columns[1:]:
#             filtered[col] = self.filter_outliers(self.data[col])
#         return self.data.iloc[self.data.iloc[:, 1].index.difference(filtered.iloc[:, 1].index)]

#     def cluster_outliers(self, cluster_data):
#         new_cluster = cluster_data['Cluster ID'].max() + 1
#         self.outliers.loc[:, 'Cluster ID'] = new_cluster
#         return pd.concat([cluster_data, self.outliers], axis=0)




# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.3.2
#   kernelspec:
#     display_name: hcii2020
#     language: python
#     name: hcii2020
# ---

# %% [markdown]
# ## Prerequisites

# %%
# imports
import pandas as pd
import os
import seaborn as sns
import networkx as nx
import matplotlib.pyplot as plt
from matplotlib import cm
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
from sklearn.linear_model import LinearRegression

# %% [markdown]
# At any point in the analysis, the configurations can be accessed through the `configs` dataframe.

# %%
# configurations for reference
configs = pd.DataFrame(
    {
        'ConfigNr': range(1, 19),
        'FriendRecTechnique': ['Hyb', 'NoN', 'Rdm'] * 6,
        'UnfriendThresh': (['low'] * 3 + ['medium'] * 3 + ['high'] * 3) * 2,
        'AgentCount': [100] * 9 + [1000] * 9
    }
)


# %% [markdown]
# ## Helper functions

# %% [markdown]
# ***Format and combine.*** For some inquiries, we need to concatenate dataframes from different runs. The formatting can be simplified with the following function.

# %%
# combine dataframes to investigate experiment variables
def format_combine(data_dict, keys):
    return pd.concat(
        [data_dict[keys[i]] for i in range(len(keys))],
        axis=0
    ).reset_index(drop=True).drop('Component', axis=1)


# %% [markdown]
# ## Load Data

# %%
# load data
data = {}
for idx in range(len(configs)):
    cfg = configs.iloc[idx, 1] + '_' + configs.iloc[idx, 2] + '_' + str(configs.iloc[idx, 3])
    data[cfg] = pd.read_csv(
        os.path.join(
            'dataexchange', 'BAfinal_run' + str(idx + 1).zfill(2), 'agent_log.csv'
        )
    )
    data[cfg]['FriendRecScheme'] = configs.iloc[idx, 1]
    data[cfg]['UnfriendThresh'] = configs.iloc[idx, 2]
    data[cfg]['AgentCount'] = str(configs.iloc[idx, 3])

# %%
# create complete dataframe
df = format_combine(data, list(data.keys()))

# %%
df.head()

# %% [markdown]
# ## Idea 1: Build Models on Final States

# %% [markdown]
# ### Linear Model

# %% [markdown]
# The following is a linear regression model to predict an agent's opinion from the other attributes. 

# %%
# subset data to retain only final state
model_1_data = df[df['TickNr'] == 1000]
model_1_data = model_1_data.loc[
    :, 
    [
        'PerceivPublOpinion', 
        'Indegree', 
        'Outdegree', 
        'Centrality', 
        'CC', 
        'Opinion'
    ]
]

# %%
# scale data to [0, 1]
for col_name in ['PerceivPublOpinion', 'Indegree', 'Outdegree', 'Opinion']:
    mms = MinMaxScaler()
    model_1_data[col_name] = mms.fit_transform(model_1_data[[col_name]])

# %%
# split data into features and label
X = model_1_data.drop(['Opinion'], axis=1).values
y = model_1_data['Opinion']

# %%
# perform train-test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.5, random_state=0)

# %%
# fit linear regression estimator
lm = LinearRegression()
lm.fit(X_train, y_train)

# %%
# predict test data
y_pred = lm.predict(X_test)

# %%
# performance metrics
lm.score(X_test, y_test)

# %% [markdown]
# ## Combination with Network Log

# %%
hyb_low_100_graph = nx.read_gml(os.path.join('dataexchange', 'BAv2_run01', 'graph_11.gml'), label=None)

# %%
opinion = df[
    (df['FriendRecScheme'] == 'Hyb') 
    & (df['UnfriendThresh'] == 'low') 
    & (df['AgentCount'] == '100') 
    & (df['TickNr'] == 1000)
]['Opinion']

# %%
nx.is_connected(hyb_low_100_graph.to_undirected())

# %%
plt.figure(figsize=(10, 10))
nx.draw_spring(hyb_low_100_graph, arrowsize=3, node_size=50, width=0.7, cmap=cm.get_cmap('viridis'), vmin=-1, cmax=1, node_color=opinion)

# %%

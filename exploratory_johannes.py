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
# ## Configuration Parameters
# * <font color="red">agent_count = {100, 1000}</font>  
# * m0 = 10  
# * new_follows = 10  
# * ticks = 1000  
# * <font color="red">addfriends = {'Hyb', 'NoN', 'Rdm'}</font>  
# * backfire = 0.4  
# * befriend = 0.2  
# * <font color="red">unfriend = {0.4, 0.8, 1.2}</font>  
# * own_opinion_weight = 0.95  
# * unfriend_rate = 0.05  
# * min_friends_count = 5   
#
# Parameters in red font are experiment variables.

# %%
# imports
import pandas as pd
import os
import seaborn as sns
import matplotlib.pyplot as plt

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
# ## Differences caused by Unfriend Threshold?

# %%
hyb_04_1000 = pd.read_csv(os.path.join('dataexchange', 'BAv2_run10', 'agent_log.csv'))
hyb_08_1000 = pd.read_csv(os.path.join('dataexchange', 'BAv2_run13', 'agent_log.csv'))
hyb_12_1000 = pd.read_csv(os.path.join('dataexchange', 'BAv2_run16', 'agent_log.csv'))

# %%
hyb_04_1000['UnfriendThresh'] = 'low'
hyb_08_1000['UnfriendThresh'] = 'medium'
hyb_12_1000['UnfriendThresh'] = 'high'

# %%
hybrid_1000 = pd.concat(
    [hyb_04_1000, hyb_08_1000, hyb_12_1000], axis=0
).reset_index(drop=True)

# %%
hybrid_1000['UnfriendThresh'] = hybrid_1000['UnfriendThresh'].astype('category')

# %%
hybrid_1000.columns

# %%
# reformat data
df = hybrid_1000.loc[:, ['TickNr', 'Opinion', 'UnfriendThresh']]
df = df.groupby(['TickNr', 'UnfriendThresh']).agg({'Opinion': 'mean'}).reset_index()
df.rename(mapper={'Opinion': 'MeanOpinion'}, axis=1, inplace=True)

# plot
fig, ax = plt.subplots(2, sharex=True, figsize=(15, 10))

plt.axes(ax[0])
sns.lineplot(x='TickNr', y='MeanOpinion', hue='UnfriendThresh', data=df)
plt.grid(b=True, axis='both')

plt.axes(ax[1])
sns.lineplot(x='TickNr', y='MeanOpinion', hue='UnfriendThresh', data=df)
plt.ylim(-1., 1.)
plt.grid(b=True, axis='both')
plt.show()

# %%
# reformat data
df = hybrid_1000.loc[:, ['TickNr', 'PerceivPublOpinion', 'UnfriendThresh']]
df = df.groupby(['TickNr', 'UnfriendThresh']).agg({'PerceivPublOpinion': 'mean'}).reset_index()
df.rename(mapper={'PerceivPublOpinion': 'MeanPerceivPublOpinion'}, axis=1, inplace=True)

# plot
# plot
fig, ax = plt.subplots(2, sharex=True, figsize=(15, 10))

plt.axes(ax[0])
sns.lineplot(x='TickNr', y='MeanPerceivPublOpinion', hue='UnfriendThresh', data=df)
plt.grid(b=True, axis='both')

plt.axes(ax[1])
sns.lineplot(x='TickNr', y='MeanPerceivPublOpinion', hue='UnfriendThresh', data=df)
plt.ylim(-1., 1.)
plt.grid(b=True, axis='both')
plt.show()

# %%
# reformat data
df = hybrid_1000.loc[:, ['TickNr', 'CC', 'UnfriendThresh']]
df = df.groupby(['TickNr', 'UnfriendThresh']).agg({'CC': 'mean'}).reset_index()
df.rename(mapper={'CC': 'GlobalCC'}, axis=1, inplace=True)

# plot
fig, ax = plt.subplots(2, sharex=True, figsize=(15, 10))

plt.axes(ax[0])
sns.lineplot(x='TickNr', y='GlobalCC', hue='UnfriendThresh', data=df)
plt.grid(b=True, axis='both')

plt.axes(ax[1])
sns.lineplot(x='TickNr', y='GlobalCC', hue='UnfriendThresh', data=df)
plt.ylim(-1., 1.)
plt.grid(b=True, axis='both')

plt.show()

# %% [markdown]
# ## Analysis of Components

# %%
from string import ascii_lowercase

# %%
hybrid_1000.columns

# %%
df = hybrid_1000[
    (hybrid_1000['TickNr'] == 1000) & (hybrid_1000['UnfriendThresh'] == 'high')
].loc[:, ['Opinion', 'Component', 'UnfriendThresh']]

# %%
df['Component'] = df['Component'].astype('category')

# %%
df['Component'].cat.rename_categories([ascii_lowercase[i] for i in range(len(df['Component'].cat.categories))])

# %%
len(df['Component'].cat.categories)

# %% [markdown]
# #### New Try

# %%
non_04_1000 = pd.read_csv(os.path.join('dataexchange', 'BAv2_run11', 'agent_log.csv'))
non_04_1000.head()

# %%
df = non_04_1000[non_04_1000['TickNr'] == 1000].loc[:, ['Opinion', 'Component']]

# %%
df['Component'] = df['Component'].astype('category')

# %%
df['Component'].cat.rename_categories(
    [ascii_lowercase[i] for i in range(len(df['Component'].cat.categories))],
    inplace=True
)

# %%
len(df['Component'].cat.categories)

# %%
sns.boxplot(x='Component', y='Opinion', data=df)
plt.show()

# %%
df[df['Component'] == 'b']

# %% [markdown]
# # Exploratory 1

# %%
BAv2_run01 = pd.read_csv(os.path.join('dataexchange', 'BAv2_run01', 'agent_log.csv'))

# %%
BAv2_run01.head()

# %%
sns.scatterplot(x='Opinion', y='PerceivPublOpinion', data=BAv2_run01, alpha=0.01)
plt.show()

# %%
g = sns.jointplot(
    x='Indegree', y='Outdegree', data=BAv2_run01, 
    kind='scatter', alpha=0.05)
plt.show()

# %%
opinion_dev = BAv2_run01.groupby('TickNr').agg(
    {
        'Opinion': 'mean',
        'PerceivPublOpinion': 'mean',
        'CC': 'mean'
    }
)
opinion_dev.reset_index(inplace=True)
opinion_dev.head()

# %%
fig, ax = plt.subplots(3, sharex=True, figsize=(15, 10))

plt.axes(ax[0])
sns.lineplot(x='TickNr', y='Opinion', data=opinion_dev)
plt.ylim(-0.3, 0.3)
plt.axhline(y=0, color='black', linewidth=0.7)
plt.grid(b=True, axis='both')
plt.ylabel('Opinion')

plt.axes(ax[1])
sns.lineplot(x='TickNr', y='PerceivPublOpinion', data=opinion_dev)
plt.ylim(-0.3, 0.3)
plt.axhline(y=0, color='black', linewidth=0.7)
plt.grid(b=True, axis='both')
plt.ylabel('Perceived Public Opinion')

plt.axes(ax[2])
sns.lineplot(x='TickNr', y='CC', data=opinion_dev)
plt.ylim(0, 0.3)
plt.axhline(y=0, color='black', linewidth=0.7)
plt.grid(b=True, axis='both')
plt.ylabel('Clustering Coefficient')

plt.show()

# %%
BAv2_run01.head()

# %%
from sklearn.preprocessing import MinMaxScaler

# %%
data_sub_1 = BAv2_run01.loc[:, ['TickNr', 'Indegree', 'Centrality']]

data_sub_1['Indegree_categorical'] = pd.cut(
    data_sub_1['Indegree'],
    bins=3,
    labels=['low', 'medium', 'high']
)

data_sub_2 = data_sub_1.groupby(['TickNr', 'Indegree_categorical']).agg({'Centrality': 'mean'}).reset_index()

# %%
data_sub_2.head()

# %%
sns.lineplot(x='TickNr', y='Centrality', hue='Indegree_categorical', data=data_sub_2)
plt.show()

# %%
data_sub_3 = BAv2_run01.loc[:, ['TickNr', 'Outdegree', 'PerceivPublOpinion']]

data_sub_3['Outdegree_categorical'] = pd.cut(
    data_sub_3['Outdegree'],
    bins=[0, data_sub_3['Outdegree'].mean(), data_sub_3['Outdegree'].max()],
    labels=['low', 'high']
)

data_sub_4 = data_sub_3.groupby(['TickNr', 'Outdegree_categorical']).agg({'PerceivPublOpinion': 'mean'}).reset_index()

# %%
data_sub_4.head()

# %%
plt.figure(figsize=(15, 5))
plt.grid(b=True, axis='both')
sns.lineplot(x='TickNr', y='PerceivPublOpinion', hue='Outdegree_categorical', data=data_sub_4, alpha=0.5)
plt.ylim(-0.3, 0.3)
plt.show()

# %%
BAv2_run01 = pd.read_csv(os.path.join('dataexchange', 'BAv2_run01', 'agent_log.csv'))
BAv2_run02 = pd.read_csv(os.path.join('dataexchange', 'BAv2_run02', 'agent_log.csv'))
BAv2_run03 = pd.read_csv(os.path.join('dataexchange', 'BAv2_run03', 'agent_log.csv'))

# %% [markdown]
# # New Try 3

# %%
configs.iloc[0, 1] + '_' + configs.iloc[0, 2] + '_' + str(configs.iloc[0, 3]) 

# %%
'14'.zfill(2)

# %%
data = {}
for idx in range(len(configs)):
    cfg = configs.iloc[idx, 1] + '_' + configs.iloc[idx, 2] + '_' + str(configs.iloc[idx, 3])
    data[cfg] = pd.read_csv(os.path.join('dataexchange', 'BAv2_run' + str(idx + 1).zfill(2), 'agent_log.csv'))
    data[cfg]['FriendRecScheme'] = configs.iloc[idx, 1]
    data[cfg]['UnfriendThresh'] = configs.iloc[idx, 2]
    data[cfg]['AgentCount'] = str(configs.iloc[idx, 3])

# %%
data['Hyb_low_100']


# %%
def format_combine(data_dict, keys):
    return pd.concat(
        [data_dict[keys[i]] for i in range(len(keys))],
        axis=0
    ).reset_index().drop('Component', axis=1)


# %%
data.keys()

# %%
format_combine(data, ['Hyb_low_1000', 'NoN_low_1000', 'Rdm_low_1000'])

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

# %%
import networkx as nx
import pandas as pd
import os
import matplotlib.pyplot as plt
from matplotlib import cm

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


# %%
# don't use for now...
def read_graphs(config_df, n_graphs=11):
    graphs = {}
    for idx in range(len(config_df)):
        cfg = config_df.iloc[idx, 1] + '_' + config_df.iloc[idx, 2] + '_' + str(config_df.iloc[idx, 3])
        graphs[cfg] = {}
        graph_file_list = [
                os.path.join('dataexchange', 'BAv2_run' + str(idx + 1).zfill(2), filename) 
                for filename in os.listdir(
                    os.path.join(
                        'dataexchange', 'BAv2_run' + str(idx + 1).zfill(2)
                    )
                ) 
                if 'graph' in filename
            ]
        for g in range(n_graphs):
            graphs[cfg]['graph' + str(g + 1).zfill(2)] = nx.read_gml(graph_file_list[g], label=None)
    return graphs


# %%
G = nx.read_gml(os.path.join('dataexchange', 'BAv2_run01', 'graph_11.gml'), label=None)

# %%
plt.figure(figsize=(10, 10))
nx.draw_kamada_kawai(G, arrowsize=3, node_size=30)

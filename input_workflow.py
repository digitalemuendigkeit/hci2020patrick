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
import pandas as pd
import matplotlib.pyplot as plt
import networkx as nx
import os


# %%
# function for reading post data
def read_simulation_data(batch_name, folder='dataexchange'):
    simulation_data = {}
    for run_nr in range(1, len(os.listdir(folder)) + 1):
        run_name = batch_name + '_' + 'run' + str(run_nr).zfill(2)
        simulation_data[run_name] = {}
        simulation_data[run_name]['agent_log'] = pd.read_csv(
            os.path.join(folder, run_name, 'agent_log.csv')
        )
        simulation_data[run_name]['post_log'] = pd.read_csv(
            os.path.join(folder, run_name, 'post_log.csv')
        )
    return simulation_data


# %%
simulation_data = read_simulation_data('BAfinal')


# %%
def read_simulation_graphs(batch_name, run_nr, folder='dataexchange'):
    graph_data = {}
    run_name = batch_name + '_run' + str(run_nr).zfill(2)
    graph_file_list = [
        os.path.join(
            folder, run_name, filename
        ) 
        for filename in os.listdir(
            os.path.join(
                folder, run_name
            )
        )
        if 'graph' in filename
    ]
    for i, path in enumerate(graph_file_list):
        graph_data[run_name + '_' + 'graph_' + str(i + 1).zfill(2)] = nx.read_gml(
            os.path.join(
                folder, run_name, 'graph_' + str(i + 1).zfill(2) + '.gml'
            ),
            label=None
        )
    return graph_data
        


# %%
simulation_graphs = read_simulation_graphs('BAfinal', 1)

# %%
nx.read_gml(os.path.join('dataexchange', 'BAfinal_run01', 'graph_01.gml'), label=None)

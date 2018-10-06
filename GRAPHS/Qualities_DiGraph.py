#!/usr/bin/env python3
import os, math
from itertools import combinations, chain

import cx_Oracle
import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt

pd.set_option('display.width', 1000)

cd = os.path.dirname(os.path.abspath(__file__))

# RETRIEVE DATA FROM ORACLE
conn = cx_Oracle.connect('****', encoding = "UTF-8", nencoding = "UTF-8")

sql = 'SELECT ID AS "Id", CHARACTERID AS "CharacterID", TRIM(Quality) AS "Quality", SPECIAL AS "Special" FROM Qualities'
quality_df = pd.read_sql(sql, conn)
conn.close()


def run_qual_graph(qual):    
    print('*********************'+qual+'*********************')

    # RETRIEVE CHARACTERS WITH SPECIFC QUALITY
    chars = quality_df.query("Quality=='{}'".format(qual))['CharacterID'].unique()
    curr_qual_df = quality_df[quality_df['CharacterID'].isin(chars)].query("Special==0")

    print(curr_qual_df.head())
    
    # BUILD COMBINATION LIST
    combns_ser = curr_qual_df.groupby('CharacterID')['Quality']\
                   .apply(lambda x: list(combinations(x, 2)))\
                   .rename('comb_pairs')    
    combns = sorted(list(chain.from_iterable(combns_ser.tolist())))
    
    # GENERATE NETWORK PLOT
    plt.figure(figsize=(14,8))
    
    G = nx.DiGraph()
    G.add_edges_from(combns)
                
    d = nx.degree(G)
    node_vals = [v*5 for k,v in d]
    
    pos = nx.spring_layout(G, k=5/math.sqrt(G.order()))
    nx.draw_networkx_nodes(G, pos, cmap=plt.cm.Blues, node_color='red', node_size = node_vals)
    nx.draw_networkx_labels(G, pos)
    nx.draw_networkx_edges(G, pos, edgelist=G.edges(), edge_color='gray', arrows=False)
    
    
    title_font = {'fontname':'Arial', 'size':'22', 'color':'black', 'weight':'bold'}
    plt.title('Characters with {} Quality'.format(qual.title()), **title_font)
    
    plt.savefig(os.path.join(cd, 'OUTPUTS', 'Quality_Network_Graph_{}.png'.format(qual.title())))
    plt.show()
    plt.clf()
    plt.close('all')


# TOP TEN QUALITIES
top_quals = quality_df['Quality'].value_counts().sort_values(ascending=False)[:5]

for i,j in top_quals.iteritems():
    run_qual_graph(i)


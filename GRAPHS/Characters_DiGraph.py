#!/usr/bin/env python3
import os, math
import pyodbc
import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt

pd.set_option('display.width', 1000)

cd = os.path.dirname(os.path.abspath(__file__))

# RETRIEVE DATA FROM SQL SERVER
conn = pyodbc.connect(driver = "ODBC Driver 17 for SQL Server",
                      server = "****", port = 1433, database = "****",
                      uid = "****", pwd = "****")

# DEFINE CHARACTER GRAPHING METHOD
def run_char_graph(qual):    
    print('*********************'+qual+'*********************')

    # QUERY DATABASE
    sql = """WITH cte AS (
               SELECT c.[ID], c.[Character], q.[Quality]
               FROM [Characters] c INNER JOIN [Qualities] q ON c.ID = q.CharacterID
             )
    
             SELECT c1.character AS char1, c2.character AS char2
             FROM cte As c1
             CROSS JOIN cte As c2
             WHERE c1.ID < c2.ID {condition}
              AND c1.Quality = c2.Quality
    """
    
    if qual == 'all':
        qual_cond = ''      
        chartitle = 'All Matched Characters'
        sql = sql.format(condition=qual_cond)
        character_df = pd.read_sql(sql, conn)
        
    else:
        qual_cond = 'AND c1.Quality = ?'        
        chartitle = 'Matched Characters with {} Quality'.format(qual.title())
        sql = sql.format(condition=qual_cond)
        character_df = pd.read_sql(sql, conn, params=[qual])
        
    
    character_df['pair'] = character_df.apply(lambda row: (row['char1'], row['char2']), axis=1)    
    
    combns = character_df['pair']
        
    # GENERATE NETWORK PLOT
    plt.figure(figsize=(14,8))
    rc_font = {'family':'Arial', 'size':'12'}
    plt.rc('font', **rc_font) 
    
    G = nx.DiGraph()
    G.add_edges_from(character_df['pair'])
                
    d = nx.degree(G)
    node_vals = [v*5 for k,v in d]
    
    pos = nx.spring_layout(G, k=5/math.sqrt(G.order()))
    nx.draw_networkx_nodes(G, pos, cmap=plt.cm.Blues, node_color='blue', node_size = node_vals)
    nx.draw_networkx_labels(G, pos)
    nx.draw_networkx_edges(G, pos, edgelist=G.edges(), edge_color='gray', arrows=False)
    
    
    title_font = {'fontname':'Arial', 'size':'22', 'color':'black', 'weight':'bold'}
    plt.title(chartitle, **title_font)
    
    plt.savefig(os.path.join(cd, 'OUTPUTS', 'Character_Network_Graph_{}.png'.format(qual.title())))
    plt.show()
    plt.clf()
    plt.close('all')


qual_list = ['all', 'death', 'family', 'loneliness', 'friend', 'poverty', 'ambition', 'romance']

for i in qual_list: 
    run_char_graph(i)

conn.close()

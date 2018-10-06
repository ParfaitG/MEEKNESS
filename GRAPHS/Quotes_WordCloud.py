#!/usr/bin/env python3
import os
from wordcloud import WordCloud

import pymysql
import pandas as pd
import matplotlib.pyplot as plt

cd = os.path.dirname(os.path.abspath(__file__))


# RETRIEVE DATA FROM MYSQL
conn = pymysql.connect(host='****', user='****', passwd='****', port=3306, db='****', charset='utf8')

sql = """SELECT c.`Character`, c.`Quote`, w.*
         FROM Characters c
         INNER JOIN Works w ON c.ID = w.CharacterID
      """
quotes_df = pd.read_sql(sql, conn)

conn.close()


# DEFINE QUOTE IMAGE METHOD
def run_quote_img(wtype):    
    print('*********************'+wtype+'*********************')
    
    if wtype != 'ALL':
       quotes_text = " ".join(quotes_df[quotes_df['WorksType'] == wtype]['Quote'].tolist())
       quotes_title = 'Characters of {} Quotes'.format(wtype)
       
    else:
       quotes_text = " ".join(quotes_df['Quote'].tolist())
       quotes_title = 'All Characters Quotes'
    
    # GENERATE WORD CLOUD IMAGE
    wordcloud = WordCloud().generate(quotes_text)
    
    # GENERATE NETWORK PLOT
    plt.figure(figsize=(14,8))
    title_font = {'fontname':'Arial', 'size':'22', 'color':'black', 'weight':'bold'}
    plt.title(quotes_title, **title_font)
    
    plt.imshow(wordcloud, interpolation='bilinear')
    plt.axis("off")

    plt.savefig(os.path.join(cd, 'OUTPUTS', 'Word_Cloud_Quotes_{}.png'.format(wtype)))
    plt.show()
    plt.clf()
    plt.close('all')
    

# RETRIEVE TOP FIVE WORKS
top_works = quotes_df['WorksType'].value_counts().nlargest(5).index.tolist()

run_quote_img('ALL')
for t in top_works:
    run_quote_img(t)

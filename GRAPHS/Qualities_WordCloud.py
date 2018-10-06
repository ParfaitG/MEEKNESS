#!/usr/bin/env python3
import os
from wordcloud import WordCloud

import pymysql
import pandas as pd
import matplotlib.pyplot as plt

cd = os.path.dirname(os.path.abspath(__file__))


# RETRIEVE DATA FROM MYSQL
conn = pymysql.connect(host='****', user='****', passwd='****', port=3306, db='****', charset='utf8')

quality_df = pd.read_sql("SELECT * FROM Qualities", conn)
quality_df['Quality'] = quality_df['Quality'].str.strip()

conn.close()


# DEFINE QUALITY IMAGE METHOD
def run_qual_img(qual):    
    print('*********************'+qual+'*********************')

    if qual != 'ALL':
        # RETRIEVE CHARACTERS WITH SPECIFC QUALITY
        chars = quality_df.query("Quality=='{}'".format(qual))['CharacterID'].unique()
        curr_qual_df = quality_df[quality_df['CharacterID'].isin(chars)].query("Special==0")
        # RETRIEVE ALL QUALITIES
        qual_text = " ".join(curr_qual_df['Quality'].tolist())
        qual_title = 'Characters with {} Quality'.format(qual.title())
    
    else:
        qual_text = " ".join(quality_df['Quality'].tolist())
        qual_title = 'All Characters Qualities'
    
    # GENERATE WORD CLOUD IMAGE
    wordcloud = WordCloud().generate(qual_text)
    
    # GENERATE NETWORK PLOT
    plt.figure(figsize=(14,8))
    title_font = {'fontname':'Arial', 'size':'22', 'color':'black', 'weight':'bold'}
    plt.title(qual_title, **title_font)
    
    plt.imshow(wordcloud, interpolation='bilinear')
    plt.axis("off")

    plt.savefig(os.path.join(cd, 'OUTPUTS', 'Word_Cloud_Quality_{}.png'.format(qual.title())))
    plt.show()
    plt.clf()
    plt.close('all')
    

# TOP TEN QUALITIES
top_quals = quality_df['Quality'].value_counts().sort_values(ascending=False)[:5]

run_qual_img('ALL')
for i,j in top_quals.iteritems():
    run_qual_img(i)

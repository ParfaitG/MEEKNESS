#!/usr/bin/env python3
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

import vaderSentiment.vaderSentiment as vd
import ibm_db, ibm_db_dbi

cd = os.path.dirname(os.path.abspath(__file__))

# RETRIEVE DATA FROM DB2
db = ibm_db.connect("****", "", "")
conn = ibm_db_dbi.Connection(db)

sql = """SELECT c.ID, c.Character, w.Title, w.WorksType, w.YearCreated, c.Quote
         FROM Characters c 
         INNER JOIN Works w ON c.ID = w.CharacterID
      """
quotes_df = pd.read_sql(sql, conn)


# DEFINE AND RUN SENTIMENT INTENSITY ANALYZER
def analyzer_cols(row):    

    # INITIALIZE VADER    
    analyzer = vd.SentimentIntensityAnalyzer()

    # RETRIEVE SCORES
    scores = analyzer.polarity_scores(row['QUOTE'])

    row['neg'] = scores['neg']
    row['neu'] = scores['neu']
    row['pos'] = scores['pos']
    row['compound'] = scores['compound']
    
    return row

quotes_df = quotes_df.apply(analyzer_cols, axis=1)


# BUILD SENTIMENT SCORE GRAPHS BY WORKS TYPE
sns.set()
sns.set_color_codes(palette='deep')

for i, g in quotes_df.groupby('WORKSTYPE'):
    fig, ax = plt.subplots(figsize=(25, 10))
    
    graph_df = (g.set_index('CHARACTER')
                 .sort_index()
                 .reindex(['neg', 'neu', 'pos', 'compound'], axis='columns')
                 .plot(kind='bar', rot=90, ax=ax)
                )
    
    plt.title('Meekness Works Type - {}'.format(i), weight='bold', size=24)
    plt.xlabel('Character', weight='bold', size=18)
    plt.ylabel('Sentiment Score', weight='bold', size=18)

    plt.tight_layout()
    plt.savefig(os.path.join(cd, 'OUTPUTS', 'Quotes_Sentiment_{}.png'.format(i)))
    plt.show()

    plt.clf()
    plt.close()





import io, os
import json
from collections import OrderedDict

import pymssql
import psycopg2

cd = os.path.dirname(os.path.abspath(__file__))

def saveJSON(jdata, fname):
    print(jdata)
    with open(os.path.join(cd, 'OUTPUT', fname), 'w') as f:
       f.write(jdata)

    print("Successfully outputted JSON data!")

#######################
### SQL SERVER
#######################
def sqlserver_buildJSON():
    conn = pymssql.connect(server='*****', user='***', password='***', database='Meekness', port=1433)

    sql = """SELECT id, c.Character, c.Source, c.LinkImage,
                    (SELECT q.Quality FROM Qualities q
                     WHERE q.CharacterID = c.ID
                     FOR JSON PATH) AS Qualities
             FROM Characters c
             ORDER BY c.ID
             FOR JSON PATH"""

    cur = conn.cursor()
    cur.execute(sql)

    char = ''
    for row in cur.fetchall():
       char += row[0]

    cur.close()
    conn.close()

    json_data = json.loads(char, object_pairs_hook=OrderedDict)
    json_data = json.dumps(json_data, indent=4)

    saveJSON(json_data, 'JSONData_SQLServer.json')


#######################
### POSTGRES
#######################
def postgres_buildJSON():
    conn = psycopg2.connect(host='*****', user='***', password='***', dbname='meekness', port=5432)

    sql = """SELECT ROW_TO_JSON(t)
             FROM 
                (SELECT c.Character, c.Description, c.Quote, c.LinkImage, 
                        (SELECT array_agg(q)
                         FROM (SELECT Quality AS "quality"
                               FROM Qualities
                               WHERE CharacterID = c.ID) q
                         ) AS "Qualities",
                        (SELECT array_agg(w)
                         FROM (SELECT Title, Creator, YearCreated, YearPeriod, WorksType, Company, OtherCreator
                               FROM Works
                               WHERE CharacterID = c.ID) w
                         ) AS "Works"
                 FROM Characters c
                 ORDER BY c.ID) t"""

    cur = conn.cursor()
    cur.execute(sql)

    char = []

    for row in cur.fetchall():
       tmp = row[0]

       q = [{n:v} for n,i in enumerate(tmp['Qualities']) for k,v in i.items()]
       t = q[0]
       for i in q[1:]:
           for k,v in i.items():
             t[k] = v

       w = OrderedDict([('title', tmp['Works'][0]['title']), 
                        ('creator', tmp['Works'][0]['creator']),
                        ('yearcreated', tmp['Works'][0]['yearcreated']),
                        ('yearperiod', tmp['Works'][0]['yearperiod']),
                        ('workstype', tmp['Works'][0]['workstype']),
                        ('company', tmp['Works'][0]['company']),
                        ('othercreator', tmp['Works'][0]['othercreator'])])

       char.append(OrderedDict([('character', tmp['character']), ('description', tmp['description']), ('quote', tmp['quote']), 
                                ('linkimage', tmp['linkimage']), ('qualities', t),  ('works', w)]))
       
    cur.close()
    conn.close()

    json_data = json.dumps(char, indent=4)
    
    saveJSON(json_data, 'JSONData_Postres.json')

postgres_buildJSON()



import os
import lxml.etree as et

import cx_Oracle
import pymssql
import ibm_db
import psycopg2

cd = os.path.dirname(os.path.abspath(__file__))


def saveXML(doc, fname):
    res = et.tostring(doc, pretty_print=True)
    print(res.decode('utf-8'))

    with open(os.path.join(cd, 'OUTPUT', fname), 'wb') as f:
       f.write(res)
    
    print("Successfully outputted XML data!")



#######################
### SQL SERVER
#######################
def sqlserver_buildXML():
    conn = pymssql.connect(server='*****', user='***', password='***', database='Meekness', port=1433)

    sql = """SELECT 1 AS Tag,
                   NULL AS Parent,
                   Character.ID AS [CHARACTER!1!ID!ELEMENT],  
                   Character AS [CHARACTER!1!NAME!ELEMENT],
                   Source AS [CHARACTER!1!SOURCE!ELEMENT],
                   LinkImage AS [CHARACTER!1!LINKIMAGE!ELEMENT],
                   Description AS [CHARACTER!1!DESCRIPTION!ELEMENT],
                   (SELECT  1 AS [Tag], NULL AS [Parent], Special AS [QUALITY!1!special], Quality AS [QUALITY!1!!XML]
                    FROM Qualities
                    WHERE Qualities.CharacterID = Character.ID
                    FOR XML EXPLICIT, TYPE)  AS [CHARACTER!1!QUALITIES!ELEMENT]        
             FROM Characters AS Character

             FOR XML EXPLICIT"""

    cur = conn.cursor()
    cur.execute(sql)

    xml = '<CHARACTERS>' + ''.join(row[0] for row in cur.fetchall()) + '</CHARACTERS>'

    cur.close()
    conn.close()

    root = et.fromstring(xml)
    saveXML(root, "XMLData_SQLServer.xml")



#######################
### ORACLE
#######################
def oracle_buildXML():
    conn = cx_Oracle.connect('***/***@*****/xe', encoding = "UTF-8", nencoding = "UTF-8")

    sql = """SELECT XMLElement("CHARACTER", 
                      XMLForest(ID, Character, Source, LinkImage, Description),
                   XMLElement("QUALITIES",
                     (SELECT XMLAgg(XMLElement("QUALITY",
                                    XMLAttributes(special as "special"), 
                                     Quality))
                      FROM Qualities sub
                      WHERE sub.CharacterID = c.ID))).GETCLOBVAL() AS "OUTPUT"
             FROM Characters c
             ORDER BY c.ID"""

    cur = conn.cursor()
    cur.execute(sql)

    root = et.Element('CHARACTERS')

    for row in cur.fetchall():
       char = et.fromstring(row[0].read())
       root.append(char)

    del row

    cur.close()
    conn.close()

    saveXML(root, "XMLData_Oracle.xml")



#######################
### DB2
#######################
def db2_buildXML():

    conn = ibm_db.connect("Server=127.0.0.1;Port=48000;Hostname=*****;Database=MEEKNESS;UID=***;PWD=***;", "", "")

    sql = """SELECT XML2CLOB(
                 XMLELEMENT(NAME "CHARACTER",
                    XMLELEMENT(NAME ID, c.ID),
                    XMLELEMENT(NAME NAME, c.Character),
                    XMLELEMENT(NAME SOURCE, c.Source),
                    XMLELEMENT(NAME LINKIMAGE, c.LinkImage),
                    XMLELEMENT(NAME "QUALITIES",
                      XMLAGG(       
                          XMLELEMENT(NAME QUALITY, 
                              XMLATTRIBUTES(CAST(q.Special AS INT) AS "special"), q.Quality)
                      )
                    )
                ))
             FROM Characters c
             INNER JOIN Qualities q
                ON c.ID = q.CharacterID
             GROUP BY c.ID, c.Character, c.Source, c.LinkImage"""

    stmt = ibm_db.exec_immediate(conn, sql)
    result = ibm_db.fetch_tuple(stmt)

    root = et.Element('CHARACTERS')

    if conn:
        while(result):
            char = et.fromstring(result[0])
            root.append(char)
            result = ibm_db.fetch_tuple(stmt)

    saveXML(root, "XMLData_DB2.xml")



#######################
### POSTGRES
#######################
def postgres_buildXML():

    conn = psycopg2.connect(host='*****', user='***', password='***', dbname='meekness', port=5432)

    sql = """SELECT XMLELEMENT(NAME "CHARACTER",
                       XMLELEMENT(NAME "ID", c.ID),
                       XMLELEMENT(NAME "NAME", c.Character),
                       XMLELEMENT(NAME "SOURCE", c.Source),
                       XMLELEMENT(NAME "LINKIMAGE", c.LinkImage),
                       XMLELEMENT(NAME "QUALITIES",
                       XMLAGG(       
                          XMLELEMENT(NAME "QUALITY", 
                              XMLATTRIBUTES(q.special), q.Quality)
                       ))
                    )
                    
             FROM Characters c
             INNER JOIN Qualities q
                ON c.ID = q.CharacterID
             GROUP BY c.ID, c.Character, c.Source, c.LinkImage"""


    cur = conn.cursor()
    cur.execute(sql)

    root = et.Element("CHARACTERS")

    for row in cur.fetchall():
       char = et.fromstring(row[0])
       root.append(char)

    cur.close()
    conn.close()

    saveXML(root, "XMLData_Postgres.xml")


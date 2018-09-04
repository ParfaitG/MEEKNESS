
import base64
import MySQLdb

from flask import Flask
from flask import render_template, request
from flask import jsonify, flash

app = Flask(__name__)
app.secret_key = "888801"

def connection():
    dbconn = MySQLdb.connect(host = "****",
                             user = "***",
                             passwd = "***",
                             db = "****")
    cur = dbconn.cursor()
    return (cur, dbconn)


@app.route('/', methods= ['GET',  'POST'])
def getdata(pick=44):
    c, db = connection()

    # RETRIEVE ALL CHARACTERS
    sql = """SELECT c.ID, c.`Character`
	         FROM Characters c
             ORDER BY c.`Character`;"""
    c.execute(sql)

    char_data = c.fetchall()

    # RETRIEVE SPECIFIC CHARACTER
    sql = """SELECT c.`Character`, c.`Description`, c.`Quote`, c.`Picture`
	         FROM Characters c
	         WHERE c.ID = %s;"""

    c.execute(sql, (pick,))

    for row in c.fetchall():
        pic_data = 'data:image/jpeg;base64,{}'.format(base64.encodestring(row[3]).decode('ascii'))
        data = {'Chars': char_data, 'Character':row[0], 'Description':row[1], 'Picture': pic_data, 'Quote':row[2], 
                'Qualities':{}, 'MatchedChars': {}, 'MatchedQuals': {}}

    # RETRIEVE CHARACTER'S QUALITIES
    sql = """SELECT q.Quality
             FROM Characters c
             INNER JOIN Qualities q ON c.ID = q.CharacterID
             WHERE c.ID = %s;"""

    c.execute(sql, (pick,))

    for i, row in enumerate(c.fetchall()):
        data['Qualities'][i] = row[0]

    # RETRIEVE TOP 5 CHARACTERS QUALITIES
    sql = """SELECT c2.ID, c2.Character As MatchedChar
                FROM 
                 (SELECT c.ID, c.`Character`, q.Quality
                  FROM `Characters` c
                  INNER JOIN Qualities q ON c.ID = q.CharacterID
                 ) c1
                INNER JOIN 
                 (SELECT c.ID, c.`Character`, q.Quality 
                  FROM `Characters` c
                  INNER JOIN Qualities q ON c.ID = q.CharacterID
                 ) c2 ON c1.Quality = c2.Quality
                WHERE c1.ID = %s AND c2.ID <> %s
                GROUP BY c1.`Character`, c2.ID, c2.`Character`
                ORDER BY Count(*) DESC;"""

    c.execute(sql, (pick, pick))

    sql_data = c.fetchall()
    for i, row in enumerate(sql_data):
        if i < 5:
            data['MatchedChars'][i] = (row[0], row[1])

    data['MatchedCount'] = len(sql_data)

    # RETRIEVE TOP 5 CHARACTERS QUALITIES
    sql = """SELECT c1.Quality As MatchedQual
                FROM 
                 (SELECT c.ID, c.`Character`, q.Quality
                  FROM `Characters` c
                  INNER JOIN Qualities q ON c.ID = q.CharacterID
                 ) c1
                INNER JOIN 
                 (SELECT c.ID, c.`Character`, q.Quality 
                  FROM `Characters` c
                  INNER JOIN Qualities q ON c.ID = q.CharacterID
                 ) c2 ON c1.Quality = c2.Quality
                WHERE c1.ID = %s AND c2.ID <> %s
                GROUP BY c1.`Quality`
                ORDER BY Count(*) DESC;"""

    c.execute(sql, (pick, pick))

    for i, row in enumerate(c.fetchall()):
        if i < 5:
            data['MatchedQuals'][i] = row

    c.close()
    db.close()

    return render_template('output.html', meekdata=data)

@app.route('/character', methods=['POST'])
def character():
    return getdata(pick=request.form['meek_pick'])

if __name__ == '__main__':
    app.run(debug=True)
    

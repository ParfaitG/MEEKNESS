
import os, base64
import MySQLdb

from flask import Flask
from flask import render_template, request

cd = os.path.dirname(os.path.abspath(__file__))

app = Flask(__name__)
app.secret_key = "888801"

def connection():
    dbconn = MySQLdb.connect(host = "*****",
                             user = "***",
                             passwd = "***",
                             db = "***")
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
        data = {'Chars': char_data, 'Character':row[0], 'Description':row[1], 'Picture': pic_data, 'Quote':row[2], 'Qualities':{} }

    # RETRIEVE CHARACTER'S QUALITIES
    sql = """SELECT q.Quality
             FROM Characters c
             INNER JOIN Qualities q ON c.ID = q.CharacterID
             WHERE c.`Character` = %s;"""

    c.execute(sql, (data['Character'],))

    for i, row in enumerate(c.fetchall()):
        data['Qualities'][i] = row[0]

    c.close()
    db.close()

    return render_template('output.html', meekdata=data)

@app.route('/character', methods=['POST'])
def character():
    return getdata(pick=request.form['meek_pick'])

if __name__ == '__main__':
    app.run(debug=True)

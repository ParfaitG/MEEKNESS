#!/usr/bin/env python3
import io
import ibm_db
import ibm_db_dbi

from tkinter import *
from tkinter import ttk
from PIL import Image, ImageTk


class GUIapp():
    
    def __init__(self):
        self.root = Tk()
        self.dbConnect(orig='Emily Webb')
        self.buildControls()
        self.populateData()
        self.root.mainloop()


    def dbConnect(self, orig):

        # DB CONNECT
        self.db = ibm_db.connect("Server=127.0.0.1;Port=48000;Hostname=*****;Database=MEEKNESS;UID=***;PWD=***;", "", "")
        self.conn = ibm_db_dbi.Connection(self.db)
        self.cur = self.conn.cursor()

        # RETRIEVE ALL CHARACTERS
        sql = """SELECT c.Character
                 FROM Characters c
                 ORDER BY c.Character;"""

        self.cur.execute(sql)
        self.charlist = []
        
        for row in self.cur.fetchall():
             self.charlist.append(row[0])


        # RETRIEVE CHARACTER NAME AND PICTURE BLOB
        sql = """SELECT c.Character, c.Picture, c.Description
                 FROM Characters c
                 WHERE c.Character = ?"""

        self.cur.execute(sql, (orig,))

        for row in self.cur.fetchall():
             self.meek_char = row[0]
             self.pic_data = row[1]
             self.desc = row[2]

        # RETRIEVE CHARACTER's QUALITIES
        sql = """SELECT q.Quality
                 FROM Characters c
                 INNER JOIN Qualities q ON c.ID = q.CharacterID
                 WHERE c.Character = ?"""

        self.cur.execute(sql, (orig,))

        self.qual_list = []

        for row in self.cur.fetchall():
             self.qual_list.append(row[0])

        self.cur.close()
        self.conn.close()

    def populateData(self): 
        if len(self.guiframe.winfo_children()) > 3:
            self.charlbl.destroy()
            self.imglbl.destroy()
            self.desclbl.destroy()
            for i, q in enumerate(self.qual_list):
                getattr(self, 'q'+str(i)).destroy()

        # CHARACTER IMAGE
        self.charlbl = Label(self.guiframe, text=self.meek_char, font=("Arial", 14))
        self.charlbl.grid(row=2, column=0, sticky=W, padx=5, pady=5)

        self.img_obj = Image.open(io.BytesIO(self.pic_data))
        h, w = self.img_obj.size
        self.img_obj = self.img_obj.resize((int(1550/4), int(1000/4)), Image.ANTIALIAS)
        self.photo = ImageTk.PhotoImage(self.img_obj)

        self.imglbl = Label(self.guiframe, image=self.photo)
        self.imglbl.photo = self.photo
        self.imglbl.grid(row=3, sticky=W, padx=5, pady=5)

        # DESCRIPTION
        self.desclbl = Label(self.guiframe, text=self.desc, font=("Arial", 10, "italic"), wraplength=400)
        self.desclbl.grid(row=4, column=0, sticky=W, padx=5, pady=5)

        # QUALITY LABELS
        for i, q in enumerate(self.qual_list):
            setattr(self, 'q'+str(i), Label(self.guiframe, text=q, font=("Arial", 14)))
            getattr(self, 'q'+str(i)).grid(row=i+6, sticky=W, padx=5, pady=5)


    def changeChar(self, newchar):
        self.dbConnect(newchar)
        self.populateData()


    def buildControls(self):  
     
	# INITIALIZE MAIN WINDOW      
        self.root.wm_title("Meekness Characters")
        self.root.iconphoto(True, PhotoImage(file="python.png"))

        self.guiframe = Frame(self.root, width=750, height=250, bd=1, relief=FLAT)
        self.guiframe.pack(padx=5, pady=5)

	# DATABASE IMAGE
        self.dbimglbl = Label(self.guiframe, text='                DB2', font=("Arial", 14)).\
                         grid(row=0, column=0, sticky=W, padx=5, pady=5)

        self.dbimg_obj = Image.open('DB2.jpg')
        h, w = self.dbimg_obj.size
        self.dbimg_obj = self.dbimg_obj.resize((int(h/2), int(w/2)), Image.ANTIALIAS)
        self.dbphoto = ImageTk.PhotoImage(self.dbimg_obj)

        self.dbimglbl = Label(self.guiframe, image=self.dbphoto)
        self.dbimglbl.photo = self.dbphoto
        self.dbimglbl.grid(row=0, column=0, sticky=W, padx=5, pady=5)

        # DROP DOWN
        self.charvar = StringVar()

        self.charcbo = ttk.Combobox(self.guiframe, textvariable=self.charvar, font=("Arial", 14), state='readonly')  
        self.charcbo['values'] = ['SELECT CHARACTER'] + self.charlist    
        self.charcbo['height'] = 30
        self.charcbo['width'] = 34
        
        self.charcbo.current(0)
        self.charcbo.grid(row=1, column=0, sticky=W, padx=5, pady=5)
        self.charcbo.bind("<<ComboboxSelected>>", lambda _: self.changeChar(newchar=self.charcbo.get()))
	

GUIapp()


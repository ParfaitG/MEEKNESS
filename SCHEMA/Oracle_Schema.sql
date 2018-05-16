CREATE TABLE Characters 
(
   ID NUMBER(5) PRIMARY KEY,
   Character VARCHAR2(255 CHAR),
   Description VARCHAR2(1000 CHAR),
   Quote VARCHAR2(1500 CHAR),
   Picture BLOB, 
   LinkImage VARCHAR2(255 CHAR)
);
CREATE SEQUENCE char_seq START WITH 1;
CREATE OR REPLACE TRIGGER char_autonum
  BEFORE INSERT ON Characters
  FOR EACH ROW
BEGIN
   :new.ID := char_seq.NEXTVAL;
END;
/
CREATE TABLE Qualities 
(
   ID NUMBER(5) PRIMARY KEY,
   CharacterID NUMBER(5),
   Quality VARCHAR2(255 CHAR),
   Special NUMBER(1),
   CONSTRAINT CharFk FOREIGN KEY (CharacterID) 
     REFERENCES Characters(ID)
);
CREATE SEQUENCE qual_seq START WITH 1;
CREATE OR REPLACE TRIGGER qual_autonum
  BEFORE INSERT ON Qualities
  FOR EACH ROW
BEGIN
   :new.ID := qual_seq.NEXTVAL;
END;
/
CREATE TABLE Works
(
   ID NUMBER(5) PRIMARY KEY,
   CharacterID NUMBER(5),
   Title VARCHAR2(255 CHAR),
   Creator VARCHAR2(255 CHAR),
   YearCreated NUMBER(5),
   YearPeriod VARCHAR(5 CHAR),
   WorksType VARCHAR2(255 CHAR),
   Company VARCHAR2(255 CHAR),
   OtherCreator VARCHAR2(255 CHAR),
   CONSTRAINT WorksFk FOREIGN KEY (CharacterID) 
     REFERENCES Characters(ID)
);
CREATE SEQUENCE works_seq START WITH 1;
CREATE OR REPLACE TRIGGER works_autonum
  BEFORE INSERT ON Works
  FOR EACH ROW
BEGIN
   :new.ID := works_seq.NEXTVAL;
END;
/
CREATE OR REPLACE FUNCTION V_blobtoclob(v_blob_in IN BLOB)
RETURN CLOB
IS
  v_file_clob    CLOB;
  v_file_size    INTEGER := DBMS_LOB.LOBMAXSIZE;
  v_dest_offset  INTEGER := 1;
  v_src_offset   INTEGER := 1;
  v_blob_csid    NUMBER := 830;
  v_lang_context NUMBER := DBMS_LOB.DEFAULT_LANG_CTX;
  v_warning      INTEGER;
  v_length       NUMBER;
BEGIN
    DBMS_LOB.CREATETEMPORARY(v_file_clob, TRUE);
    DBMS_LOB.CONVERTTOCLOB(v_file_clob, v_blob_in, v_file_size, v_dest_offset,
                           v_src_offset, v_blob_csid, v_lang_context, v_warning);
    RETURN v_file_clob;
EXCEPTION
  WHEN OTHERS THEN
             DBMS_OUTPUT.PUT_LINE('Error found');
END;
/
CREATE OR REPLACE FUNCTION blob_to_hex (blob_in IN BLOB)
RETURN CLOB
AS
    v_clob    CLOB;
    v_varchar VARCHAR2(4000);
    v_start   PLS_INTEGER := 1;
    v_buffer  PLS_INTEGER := 2000;
BEGIN
    DBMS_LOB.CREATETEMPORARY(v_clob, TRUE);    
    FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(blob_in) / v_buffer)
    LOOP        
       v_varchar := DBMS_LOB.SUBSTR(blob_in, v_buffer, v_start);
       DBMS_LOB.WRITEAPPEND(v_clob, LENGTH(v_varchar), v_varchar);
       v_start := v_start + v_buffer;
    END LOOP;    
   RETURN v_clob;  
END blob_to_hex;
/

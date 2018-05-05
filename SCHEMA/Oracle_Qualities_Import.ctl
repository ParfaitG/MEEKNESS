OPTIONS (SKIP=1)
LOAD DATA 
  INFILE "/path/to/Qualities.csv"
  INTO TABLE "MEEKDBA"."QUALITIES"
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' 
  (CharacterID CHAR(255), 
   Quality     CHAR(255), 
   Special     CHAR(255))

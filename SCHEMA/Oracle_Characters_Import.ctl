OPTIONS (SKIP=1)
LOAD DATA 
   INFILE "/path/to/Characters.csv"
   INTO TABLE "MEEKDBA"."CHARACTERS"
   FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' 
   (Character   CHAR(255), 
    Description CHAR(1000),
    Quote       CHAR(1000), 
    LinkImage   CHAR(255),
    Picture     LOBFILE(LinkImage) TERMINATED BY EOF)

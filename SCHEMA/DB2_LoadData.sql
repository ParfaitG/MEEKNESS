LOAD FROM "/path/to/CharactersSQL.csv"
  OF DEL
  LOBS FROM /path/to/
  MODIFIED BY LOBSINFILE CHARDEL""
  DUMPFILE="/path/to/CharactersLoad_Dump.txt"
  METHOD P (1,2,3,4,5)
  MESSAGES "/path/to/CharactersLoad_Msg.txt"
  REPLACE INTO "CHARACTERS"
  (CHARACTER,
   DESCRIPTION,
   SOURCE,
   QUOTE,
   LINKIMAGE,
   PICTURE);

LOAD FROM "/path/to/Qualities_DB2.csv"
  OF DEL
  MODIFIED BY CHARDEL""
  DUMPFILE="/path/to/QualitiesLoad_Dump.txt"
  METHOD P (1,2,3)
  MESSAGES "/path/to/QualitiesLoad_Msg.txt"
  REPLACE INTO "QUALITIES"
  (CHARACTERID,
   QUALITY,
   SPECIAL);


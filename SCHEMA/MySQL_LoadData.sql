LOAD DATA LOCAL INFILE '/path/to/CharactersMySQL.csv' INTO TABLE Characters
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(`Character`, `Description`, `Quote`, `LinkImage`);

LOAD DATA  LOCAL INFILE '/path/to/Qualities.csv' INTO TABLE Qualities
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(`CharacterID`, `Quality`, `Special`);

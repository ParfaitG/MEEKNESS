CREATE TABLE Characters (
   `ID` INTEGER PRIMARY KEY,
   `Character` TEXT,
   `Description` TEXT,
   `Quote` TEXT,
   `LinkImage` TEXT,
   `Picture` BLOB
);

CREATE TABLE Qualities (
   `ID` INTEGER PRIMARY KEY,
   `CharacterID` INTEGER,
   `Quality` TEXT,
   `Special` INTEGER,
   FOREIGN KEY (CharacterID) REFERENCES Characters (ID)
);

CREATE TABLE Works (
   `ID` INTEGER PRIMARY KEY,
   `CharacterID` INTEGER,
   `Title` VARCHAR(255),
   `Creator` VARCHAR(255),
   `YearCreated` INTEGER,
   `YearPeriod` VARCHAR(5),
   `WorksType` VARCHAR(255),
   `Company` VARCHAR(255),
   `OtherCreator` VARCHAR(255),
   FOREIGN KEY (CharacterID) REFERENCES Characters (ID)
);

CREATE TABLE Characters (
   `ID` INT AUTO_INCREMENT PRIMARY KEY,
   `Character` VARCHAR(255),
   `Description` VARCHAR(1300),
   `Source` VARCHAR(255),
   `Quote` VARCHAR(1300),
   `LinkImage` VARCHAR(255),
   `Picture` MEDIUMBLOB
);

CREATE TABLE Qualities (
   `ID` INT AUTO_INCREMENT PRIMARY KEY,
   `CharacterID` INT,
   `Quality` VARCHAR(255),
   `Special` BOOLEAN,
   FOREIGN KEY (CharacterID) REFERENCES Characters (ID)
);

CREATE TABLE Works (
   `ID` INT AUTO_INCREMENT PRIMARY KEY,
   `CharacterID` INT,
   `Title` VARCHAR(255),
   `Creator` VARCHAR(255),
   `YearCreated` INT,
   `YearPeriod` VARCHAR(5),
   `WorksType` VARCHAR(255),
   `Company` VARCHAR(255),
   `OtherCreator` VARCHAR(255),
   FOREIGN KEY (CharacterID) REFERENCES Characters (ID)
);

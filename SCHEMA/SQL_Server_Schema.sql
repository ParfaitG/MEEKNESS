USE Meekness;
GO

CREATE TABLE Characters (
   ID INT IDENTITY(1,1) PRIMARY KEY,
   [Character] VARCHAR(255),
   Description VARCHAR(1250),
   Quote VARCHAR(1250),
   LinkImage VARCHAR(255),
   Picture VARBINARY(MAX)
);

CREATE TABLE Qualities (
   ID INT IDENTITY(1,1) PRIMARY KEY,
   CharacterID INT,
   Quality VARCHAR(255),
   Special BIT,
   CONSTRAINT FK_Character FOREIGN KEY (CharacterID) REFERENCES Characters (ID)
);

CREATE TABLE Works (
   ID INT IDENTITY(1,1) PRIMARY KEY,
   CharacterID INT,
   Title VARCHAR(255),
   Creator VARCHAR(255),
   YearCreated INT,
   YearPeriod VARCHAR(5),
   WorksType VARCHAR(255),
   Company VARCHAR(255),
   OtherCreator VARCHAR(255),
   CONSTRAINT FK_Works FOREIGN KEY (CharacterID) REFERENCES Characters (ID)
);

GO

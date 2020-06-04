-------------------------------
-- LOOK UP STORED PROCEDURES --
-------------------------------

USE Proj_A10
GO 

CREATE PROCEDURE getGameID
@GName VARCHAR(50),
@GID INT OUTPUT 
AS
SET @GID = (SELECT GameID FROM tblGAME 
    WHERE GameName = @GName)
GO 

CREATE PROCEDURE getKeywordID 
@KeyName VARCHAR(50),
@KeyID INT OUTPUT 
AS 
SET @KeyID = (SELECT KeywordID FROM tblKEYWORD WHERE KeywordName = @KeyName)
GO

CREATE PROCEDURE getPlatformID
@PName VARCHAR(50),
@PID INT OUTPUT
AS 
SET @PID = (SELECT PlatformID FROM tblPlatform 
    WHERE PlatformName = @PName)
GO

CREATE PROCEDURE getGenderID
@GName VARCHAR(50),
@GID INT OUTPUT
AS 
SET @GID = (SELECT GenderID FROM tblGender 
    WHERE GenderName = @GName)
GO

CREATE PROCEDURE getLanguageID 
@LangName VARCHAR(50),
@LangID INT OUTPUT 
AS 
SET @LangID = (SELECT LanguageID FROM tblLANGUAGE 
    WHERE LanguageName = @LangName)
GO 

CREATE PROCEDURE getGamerID 
@G_Fname VARCHAR(50),
@G_Lname VARCHAR(50),
@G_Gender VARCHAR(50),
@G_DOB VARCHAR(50),
@G_ID VARCHAR(50) OUTPUT
AS 

DECLARE @Gender_ID INT = (SELECT GenderID FROM tblGENDER WHERE GenderName = @G_Gender)
IF @Gender_ID IS NULL 
BEGIN 
    RAISERROR('Gender ID cannot be null! Please input correct gender name', 11, 1)
    RETURN
END

SET @G_ID = (SELECT GamerID FROM tblGAMER 
    WHERE GamerFname = @G_Fname AND 
    GamerLname = @G_Lname AND 
    GamerDOB = @G_DOB AND 
    GenderID = @Gender_ID)
GO

CREATE PROCEDURE getPerspective
@PerName VARCHAR(50),
@PerID INT OUTPUT 
AS 
SET @PerID = (SELECT PerpID FROM tblPERSPECTIVE 
    WHERE PerpName = @PerName)
GO 

CREATE PROCEDURE getRegionID
@RegName VARCHAR(20),
@Reg_ID INT OUTPUT
AS
SET @Reg_ID = (SELECT RegionID
			  FROM tblREGION
			  WHERE @RegName = RegionName)
GO

CREATE PROCEDURE getGenreTypeID
@GTypeName VARCHAR(20),
@GType_ID INT OUTPUT
AS
SET @GType_ID = (SELECT GenreTypeID
			  FROM tblGENRE_TYPE
			  WHERE @GTypeName = GenreTypeName)
GO

CREATE PROCEDURE getParentRateID
@PRateName VARCHAR(20),
@PRate_ID INT OUTPUT
AS
SET @PRate_ID = (SELECT ParentRateID
				FROM tblPARENT_RATE
				WHERE @PRateName = ParentRateName)
GO

CREATE PROCEDURE GetDeveloperID
@DevName	varchar(50),
@DevID		INT OUTPUT
AS 
SET @DevID = (SELECT DeveloperID FROM tblDEVELOPER WHERE DeveloperName = @DevName)
GO

CREATE PROCEDURE GetPublisherID
@PubName	varchar(50),
@PubID		INT OUTPUT
AS 
SET @PubID = (SELECT PublisherID FROM tblPublisher WHERE PublisherName = @PubName)
GO

CREATE PROCEDURE getOrderID
@GFname varchar(50),
@GLname varchar(50),
@Gender varchar(50),
@GDOB DATE,
@ODate DATE,
@OTotal numeric (5,2),
@OID INT OUTPUT
AS

DECLARE @GmerID INT

EXEC getGamerID
@G_Fname = @GFname,
@G_Lname = @GLname,
@G_Gender = @Gender,
@G_DOB = @GDOB,
@G_ID = @GmerID OUTPUT
IF @GmerID IS NULL 
BEGIN 
    RAISERROR('Gamer ID cannot be null!', 11, 1)
    RETURN
END

SET @OID = (SELECT OrderID 
				FROM tblORDER 
				WHERE GamerID = @GmerID
				AND OrderDate = @ODate
				AND OrderTotal = @OTotal
				)
GO

CREATE PROCEDURE getOrderGameID
@GName VARCHAR(50),
@PName VARCHAR(50),
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@Gender VARCHAR(50),
@BDate	DATE,
@ODate	DATE,
@OTotal NUMERIC (5,2),
@OGID INT OUTPUT
AS

DECLARE @GID INT, @PID INT, @OID INT

EXEC getGameID
@GName = @GName,
@GID = @GID OUTPUT 
IF @GID IS NULL 
BEGIN 
    RAISERROR('Game ID cannot be null!', 11, 1)
    RETURN
END

EXEC getPlatformID
@PName = @PName,
@PID = @PID OUTPUT
IF @PID IS NULL 
BEGIN 
    RAISERROR('Platform ID cannot be null!', 11, 1)
    RETURN
END

EXEC getOrderID
@GFname = @Fname,
@GLname = @Lname,
@Gender = @Gender,
@GDOB   = @BDate,
@ODate	= @ODate,
@OTotal = @OTotal,
@OID	= @OID OUTPUT
IF @OID IS NULL 
BEGIN 
    RAISERROR('ORDER ID cannot be null!', 11, 1)
    RETURN
END

SET @OGID = (
SELECT OrderGameID
FROM tblORDER_GAME
WHERE GameID = @GID
AND OrderID = @OID
AND PlatformID = @PID
)

GO
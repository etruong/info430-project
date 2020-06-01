-----------------------
-- STORED PROCEDURES --
-----------------------

USE info430_gp10_VideoGame
GO 

-- LOOK UP PROCEDURES
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

-- INSERT PROCEDURES
CREATE PROCEDURE insertCartItem
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@DOB DATE,
@Gender VARCHAR(50),
@Game_Name VARCHAR(50),
@Plat_Name VARCHAR(50),
@Quantity INT
AS 

DECLARE @Game_ID INT, @Plat_ID INT, @Cust_ID INT

EXEC getGamerID
@G_Fname = @Fname,
@G_Lname = @Lname,
@G_Gender = @Gender,
@G_DOB = @DOB,
@G_ID = @Cust_ID OUTPUT
IF @Cust_ID IS NULL 
BEGIN 
    RAISERROR('Gamer ID cannot be null!', 11, 1)
    RETURN
END

EXEC getGameID
@GName = @Game_Name,
@GID = @Game_ID OUTPUT 
IF @Game_ID IS NULL 
BEGIN 
    RAISERROR('Game ID cannot be null!', 11, 1)
    RETURN
END

EXEC getPlatformID
@PName = @Plat_Name,
@PID = @Plat_ID OUTPUT
IF @Plat_ID IS NULL 
BEGIN 
    RAISERROR('Platform ID cannot be null', 11, 1)
    RETURN
END

DECLARE @Price MONEY = (SELECT pph.HistoryPrice FROM tblPlatform_Price_History AS pph
    JOIN tblGamePlatform AS gp ON gp.GamePlatformID = pph.GamePlatformID
    WHERE gp.GameID = @Game_ID AND 
    gp.PlatformID = @Plat_ID AND 
    pph.HistoryCurrent = 'true')
IF @Price IS NULL 
BEGIN 
    RAISERROR('Price of game cannot be null', 11, 1)
    RETURN
END

DECLARE @Subprice MONEY = @Price * @Quantity

BEGIN TRAN addItemToCart
    INSERT INTO tblCART(GamerID, GameID, PlatformID, CartQty, CartSubprice, GamePrice)
    VALUES (@Cust_ID, @Game_ID, @Plat_ID, @Quantity, @Subprice, @Price)

    IF @@ERROR<> 0 
    BEGIN 
        PRINT('Ran into error while adding item to cart!')
        ROLLBACK TRAN addItemToCart 
    END
    ELSE 
        COMMIT TRAN addItemToCart 
GO 

-- PROCESS CART PROCEDURE
CREATE PROCEDURE processCart 
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@DOB DATE,
@Gender VARCHAR(50),
@PurchaseDate DATE
AS 

DECLARE @Cust_ID INT

EXEC getGamerID
@G_Fname = @Fname,
@G_Lname = @Lname,
@G_Gender = @Gender,
@G_DOB = @DOB,
@G_ID = @Cust_ID OUTPUT
IF @Cust_ID IS NULL 
BEGIN 
    RAISERROR('Gamer ID cannot be null!', 11, 1)
    RETURN
END

DECLARE @OrderSum MONEY = (SELECT SUM(CartSubprice) FROM tblCART WHERE GamerID = @Cust_ID)
BEGIN TRAN insertOrder
    INSERT INTO tblORDER(OrderDate, OrderTotal)
    VALUES (@PurchaseDate, @OrderSum)

    DECLARE @Order_ID INT = (SELECT SCOPE_IDENTITY())
    IF @Order_ID IS NULL 
    BEGIN 
        RAISERROR('Order ID cannot be null!', 11, 1)
        RETURN
    END

    INSERT INTO tblORDER_GAME (OrderID, PlatformID, GameID, OrderGameQty, OrderGameSubprice, GamePrice)
        SELECT @Order_ID, PlatformID, GameID, SUM(CartQty), SUM(CartSubprice), GamePrice 
        FROM tblCART 
        WHERE GamerID = @Cust_ID 
        GROUP BY PlatformID, GameID, GamePrice
    IF @@ERROR <> 0 
    BEGIN 
        PRINT('Error inserting Order Game content')
        ROLLBACK TRAN insertOrder
    END 
    ELSE 
        COMMIT TRAN insertOrder
    
PRINT @@RowCount
    DELETE FROM tblCART 
    WHERE GamerID = @Cust_ID
GO

------- Marcus ------
-- tblGAME: InsertGame
CREATE PROCEDURE insertGame
@GName varchar(50),
@GReleaseDate DATE,
@GDescription varchar(100),
@PRateName varchar(30),
@PerName varchar(30),
@GeTName varchar(30)

AS
DECLARE @GT_ID INT, @P_ID INT, @PR_ID INT

EXEC getGenreTypeID
@GTypeName = @GeTName,
@GType_ID = @GT_ID OUTPUT
IF @GT_ID IS NULL
BEGIN
	RAISERROR('GenreTypeID cannot be null', 11,1)
	RETURN
END

EXEC getParentRateID
@PRateName = @PrateName,
@PRate_ID = @PR_ID OUTPUT
IF @PR_ID IS NULL
BEGIN
	RAISERROR('ParentRateID cannot be null', 11,1)
	RETURN
END

EXEC getPerspective
@PerName = @PerName,
@PerID = @P_ID OUTPUT
IF @P_ID IS NULL
BEGIN
	RAISERROR('PerspectiveID cannot be null', 11,1)
	RETURN
END
--computed columns are price range and avg rating

BEGIN TRAN addGame
	INSERT INTO tblGAME(GameName, GenreTypeID, GameReleaseDate, GameDescription, PerpID, ParentRateID)
	VALUES (@GName, @GT_ID, @GReleaseDate, @GDescription, @P_ID, @PR_ID)
	
	IF @@ERROR<> 0
	BEGIN
		PRINT('Ran into error while inserting a game')
		ROLLBACK TRAN addGame
	END
	ELSE
		COMMIT TRAN addGame
GO


-- tblREVIEW: InsertReview
CREATE PROCEDURE insertREVIEW
@RRating float,
@RContent varchar(255),
@RDate DATE,
@GameName varchar(50),
@GamerFname varchar(50),
@GamerLname varchar(50),
@GamerBday DATE,
@OrderDate DATE, 
@PlatformName varchar(50),
@Gender varchar(50)
AS
DECLARE @OG_ID INT

EXEC getOrderGameID
@GName = @GameName,
@PName = @PlatformName,
@FName = @GamerFname,
@LName = @GamerLname,
@Gender = @Gender,
@BDate = @GamerBday,
@ODate = @OrderDate,
@OGID = @OG_ID OUTPUT
IF @OG_ID IS NULL
BEGIN
	RAISERROR('ParentRateID cannot be null', 11,1)
	RETURN
END

BEGIN TRAN addReview
	INSERT INTO tblREVIEW(OrderGameID, ReviewRating, ReviewContent, ReviewDate)
	VALUES (@OG_ID, @RRating, @RContent, @RDate)
	
	IF @@ERROR<> 0
	BEGIN
		PRINT('Ran into error while inserting a game')
		ROLLBACK TRAN addReview
	END
	ELSE
		COMMIT TRAN addReview
GO








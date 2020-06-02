-----------------------
-- STORED PROCEDURES --
-----------------------

USE info430_gp10_VideoGame
GO 

---------------------------
-- Creator: Elisa Truong --
---------------------------

-- INSERT PROCEDURES
Alter PROCEDURE insertCartItem
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

DECLARE @Price MONEY = (SELECT gp.CurrentPrice FROM tblGamePlatform AS gp
    WHERE gp.GameID = @Game_ID AND 
    gp.PlatformID = @Plat_ID)
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
Alter PROCEDURE processCart 
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
    INSERT INTO tblORDER(GamerID, OrderDate, OrderTotal)
    VALUES (@Cust_ID, @PurchaseDate, @OrderSum)

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
    
    DECLARE @SuccessMsg VARCHAR(100) = (SELECT CONCAT('Successfully inserted information for ', @FName, ' ', @LName))
    PRINT(@SuccessMsg)
    DELETE FROM tblCART 
    WHERE GamerID = @Cust_ID
GO

---------------------------
-- Creator: Marcus Huang --
---------------------------

-- tblGAME: InsertGame
Alter PROCEDURE insertGame
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
ALTER PROCEDURE insertREVIEW
@RRating		float,
@RContent		varchar(255),
@RDate			DATE,
@GameName		varchar(50),
@GamerFname		varchar(50),
@GamerLname		varchar(50),
@GamerBday		DATE,
@OrderDate		DATE, 
@PlatformName	varchar(50),
@Gender			varchar(50),
@OTotal			numeric(5,2)
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
@OTotal = @OTotal,
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

------------------------
-- Creator: Angel Lin --
------------------------


-- Insert Procedure: tblPlatformPriceHistory --
ALTER PROCEDURE getGamePlatformID
@GN VARCHAR(50),
@PN VARCHAR(50),
@GPID INT OUTPUT
As

DECLARE @G_ID INT, @P_ID INT

EXEC getGameID
@GName = @GN,
@GID = @G_ID OUTPUT
IF @G_ID IS NULL
BEGIN 
	RAISERROR('Game ID cannot be null!', 11, 1)
	RETURN
END

EXEC getPlatformID
@PName = @PN,
@PID = @P_ID OUTPUT
IF @P_ID IS NULL
BEGIN 
	RAISERROR('Platform ID cannot be null!', 11, 1)
	RETURN
END

SET @GPID = (SELECT GamePlatformID FROM tblGamePlatform
			 WHERE GameID = @G_ID
			 AND PlatformID = @P_ID)

GO

ALTER PROCEDURE insPlatformPriceHistory
@G_Name VARCHAR(50),
@P_Name VARCHAR(50),
@H_Price MONEY,
@H_SDate DATE,
@H_EDate DATE
AS

DECLARE @GP_ID INT

EXEC getGamePlatformID
@GN = @G_Name,
@PN = @P_Name,
@GPID = @GP_ID OUTPUT
IF @GP_ID IS NULL
BEGIN 
    RAISERROR('Game Platform ID cannot be null!', 11, 1)
    RETURN
END

BEGIN TRAN addPlatformPriceHistory
		INSERT INTO tblPlatform_Price_History(GamePlatformID, HistoryPrice, HistoryStart, HistoryEnd)
		VALUES (@GP_ID, @H_Price, @H_SDate, @H_EDate)

		IF @@ERROR<> 0 
		BEGIN 
			PRINT('Ran into error while adding item to platform price history!')
			ROLLBACK TRAN addPlatformPriceHistory
		END
		ELSE 
			COMMIT TRAN addPlatformPriceHistory
GO 

-- Insert Procedure: tblGamePlatform --
Alter PROCEDURE insGamePlatform
@GN VARCHAR(50),
@PN VARCHAR(50),
@ReleaseDate DATE
AS

DECLARE @G_ID INT, @P_ID INT

EXEC getGameID
@GName = @GN,
@GID = @G_ID OUTPUT
IF @G_ID IS NULL
BEGIN 
	RAISERROR('Game ID cannot be null!', 11, 1)
	RETURN
END

EXEC getPlatformID
@PName = @PN,
@PID = @P_ID OUTPUT
IF @P_ID IS NULL
BEGIN 
	RAISERROR('Platform ID cannot be null!', 11, 1)
	RETURN
END

BEGIN TRAN addToGamePlatform
	INSERT INTO tblGamePlatform(GameID, PlatformID, PlatformReleaseDate)
	VALUES (@G_ID, @P_ID, @ReleaseDate)

	IF @@ERROR <> 0
	BEGIN
		PRINT('Ran into error while adding item to Game Platform!')
		ROLLBACK TRAN addToGamePlatform
	END
	ELSE 
		COMMIT TRAN addToGamePlatform
GO

-----------------------
-- Creator: Andi Ren --
-----------------------

Alter PROCEDURE InsertGamer 
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@DOB DATE,
@Username VARCHAR(50),
@GenderName VARCHAR(50)
AS

DECLARE @Gender_ID INT = (SELECT GenderID FROM tblGENDER WHERE GenderName = @GenderName)
IF @Gender_ID IS NULL 

BEGIN 
    RAISERROR('Gender ID cannot be null! Please input correct gender name', 11, 1)
    RETURN
END

BEGIN TRAN g1
    Insert into tblGAMER (GamerFname, GamerLname, GamerDOB, GamerUsername, GenderID) 
    VALUES (
    @Fname, @Lname, @DOB, @Username, @Gender_ID
    )
    IF @@ERROR <> 0 
    BEGIN 
        PRINT('Error inserting gamer interest row')
        ROLLBACK TRAN g1
    END 
    ELSE 
        COMMIT TRAN g1
GO

Alter PROCEDURE InsertGAMER_INTEREST
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@DOB DATE,
@Gender VARCHAR(50),
@Keyword VARCHAR(50)
AS

DECLARE @Gamer_ID INT, @Keyword_ID INT

EXEC getGamerID
@G_Fname = @Fname,
@G_Lname = @Lname,
@G_Gender = @Gender,
@G_DOB = @DOB,
@G_ID = @Gamer_ID OUTPUT
IF @Gamer_ID IS NULL 
BEGIN 
    RAISERROR('Gamer ID cannot be null!', 11, 1)
    RETURN
END

EXEC getKeywordID
@KeyName = @Keyword,
@KeyID = @Keyword_ID OUTPUT 
IF @Keyword_ID IS NULL 
BEGIN 
    RAISERROR('Keyword ID cannot be null!', 11, 1)
    RETURN
END

BEGIN TRAN g1 
    Insert into tblGAMER_INTEREST(GamerID, KeywordID) 
    VALUES (
    @Gamer_ID, @Keyword_ID
    )
    IF @@ERROR <> 0 
    BEGIN 
        PRINT('Error inserting gamer interest row')
        ROLLBACK TRAN g1
    END 
    ELSE 
        COMMIT TRAN g1
GO

ALTER PROCEDURE InsertDEVELOPER_GAME
@DevName	VARCHAR(50),
@GName		VARCHAR(50)
AS

DECLARE @GID INT, @DID INT

EXEC getGameID 
@GName = @GName,
@GID = @GID OUTPUT

IF @GID IS NULL
BEGIN 
    RAISERROR('Game ID is null', 11, 1)
    RETURN
END

EXEC GetDeveloperID 
@DevName = @DevName,
@DevID = @DID OUTPUT

IF @DID IS NULL
BEGIN 
    RAISERROR('Developer ID is null', 11, 1)
    RETURN
END

BEGIN TRAN g1 
    INSERT INTO tblDEVELOPER_GAME 
    (DeveloperID,
    GameID)
    VALUES
    (@DID,
    @GID)

    IF @@ERROR <> 0 
    BEGIN 
        PRINT('Error inserting developer game row')
        ROLLBACK TRAN g1
    END 
    ELSE 
        COMMIT TRAN g1
GO
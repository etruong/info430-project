USE info430_gp10_VideoGame
GO 

----------------------------
-- SYNTHETIC TRANSACTIONS --
----------------------------

CREATE PROCEDURE generateOrders
@RUN INT 
AS 

DECLARE @Gamer_Row INT = (SELECT COUNT(*) FROM tblGAMER)
DECLARE @GP_Row INT = (SELECT COUNT(*) FROM tblGamePlatform)

WHILE @RUN > 0
BEGIN 

    DECLARE @Gamer_PK INT = (SELECT RAND() * @Gamer_Row + 1)

    DECLARE @F VARCHAR(50), @L VARCHAR(50), @DB DATE, @Gen VARCHAR(50), @GN VARCHAR(50), @PN VARCHAR(50), @Q INT
    DECLARE @OrderItem INT = (SELECT RAND() * 5 + 1)
    SELECT 
            @F = (SELECT GamerFname FROM tblGAMER WHERE GamerID = @Gamer_PK),
            @L = (SELECT GamerLname FROM tblGAMER WHERE GamerID = @Gamer_PK),
            @DB = (SELECT GamerDOB FROM tblGAMER WHERE GamerID = @Gamer_PK),
            @Gen = (SELECT ge.GenderName FROM tblGAMER g
                JOIN tblGENDER AS ge ON ge.GenderID = g.GenderID
                WHERE GamerID = @Gamer_PK)
    
    DECLARE @GP_PK INT = (SELECT RAND() * @GP_Row + 1)
    DECLARE @Game_PK INT = (SELECT GameID FROM tblGamePlatform WHERE GamePlatformID = @GP_PK)
    DECLARE @Plat_PK INT = (SELECT PlatformID FROM tblGamePlatform WHERE GamePlatformID = @GP_PK)

    WHILE @OrderItem > 0 
    BEGIN 
        SELECT    
            @GN = (SELECT GameName FROM tblGAME WHERE GameID = @Game_PK),
            @PN = (SELECT PlatformName FROM tblPlatform WHERE PlatformID = @Plat_PK),
            @Q = (SELECT RAND() * 5 + 1)

        EXEC insertCartItem
        @Fname = @F,
        @Lname = @L,
        @DOB = @DB,
        @Gender = @Gen,
        @Game_Name = @GN,
        @Plat_Name = @PN,
        @Quantity = @Q

        SET @GP_PK = (SELECT RAND() * @GP_Row + 1)
        SET @Game_PK = (SELECT GameID FROM tblGamePlatform WHERE GamePlatformID = @GP_PK)
        SET @Plat_PK = (SELECT PlatformID FROM tblGamePlatform WHERE GamePlatformID = @GP_PK)
        
        SET @OrderItem = @OrderItem - 1
    END 

    DECLARE @PurDate DATE = (SELECT DATEADD(DD, -(SELECT RAND() * 365 * 10), GETDATE()))
    DECLARE @PurDateGamerExist INT = (SELECT COUNT(*) FROM tblORDER WHERE GamerID = @Gamer_PK AND OrderDate = @PurDate)
    WHILE @PurDateGamerExist > 0 -- Ensure no orders will be placed the same day
    BEGIN 
        SET @PurDate = (SELECT DATEADD(DD, -(SELECT RAND() * 365 * 10), GETDATE()))
        SET @PurDateGamerExist = (SELECT COUNT(*) FROM tblORDER WHERE GamerID = @Gamer_PK AND OrderDate = @PurDate)
    END 

    EXEC processCart 
    @Fname = @F,
    @Lname = @L,
    @DOB = @DB,
    @Gender = @Gen,
    @PurchaseDate = @PurDate

    SET @RUN = @RUN - 1
END 
GO

-- EXEC generateOrders
-- @RUN = 1000
-- GO 

---------------------
-- Generates reviews 
-- 
-- insertREVIEW
-- @RRating float,
-- @RContent varchar(255),
-- @RDate DATE,
-- @GameName varchar(50),
-- @GamerFname varchar(50),
-- @GamerLname varchar(50),
-- @GamerBday DATE,
-- @OrderDate DATE, 
-- @PlatformName varchar(50),
-- @Gender varchar(50)

---------------------
-- Generates price values for every game platform pair in the tblGame_Platform
-- 
CREATE PROCEDURE wrapper_insertPlatPrice 
AS 

DECLARE @GameRow INT = (SELECT COUNT(*) FROM tblGAME)

WHILE @GameRow > 0
BEGIN 
    DECLARE @tempTable TABLE (
        GamePlatformID INT,
        GameID INT,
        PlatformID INT, 
        PlatformReleaseDate DATE,
        CurrentPrice MONEY
    )
    INSERT INTO @tempTable
        SELECT * FROM tblGamePlatform WHERE GameID = @GameRow
    DECLARE @GameName VARCHAR(50) = (SELECT DISTINCT GameName FROM tblGAME WHERE GameID = @GameRow)

    WHILE (SELECT COUNT(*) FROM @tempTable) > 0
    BEGIN 
        DECLARE @MIN_PK INT = (SELECT MIN(GamePlatformID) FROM @tempTable)
        DECLARE @PlatformName VARCHAR(50) = (SELECT p.PlatformName FROM tblPlatform AS p 
            JOIN @tempTable AS gp ON p.PlatformID = gp.PlatformID WHERE gp.GamePlatformID = @MIN_PK)
        DECLARE @GameRelease DATE = (SELECT PlatformReleaseDate FROM @tempTable WHERE GamePlatformID = @MIN_PK)
        DECLARE @EndSale DATE = (SELECT DATEADD(DD, (SELECT RAND() * 100 + 1), @GameRelease))
        DECLARE @Price MONEY =  CASE 
                                    WHEN @PlatformName = 'PC' THEN '35.00'
                                    WHEN @PlatformName = 'Wii U' THEN '20.00'
                                    WHEN @PlatformName = 'PlayStation' THEN '40.00'
                                    WHEN @PlatformName = 'Playstation' THEN '40.00'
                                    WHEN @PlatformName = 'Mac' THEN '35.00'
                                    WHEN @PlatformName = 'Switch' THEN '60.00'
                                    WHEN @PlatformName = '3DS' THEN '30.00'
                                    WHEN @PlatformName = '2DS' THEN '30.00'
                                    WHEN @PlatformName = 'Xbox' THEN '60.00'
                                END
        IF @EndSale BETWEEN @GameRelease AND GETDATE()
        BEGIN 
            EXEC insPlatformPriceHistory
            @G_Name = @GameName,
            @P_Name = @PlatformName,
            @H_Price = @Price,
            @H_SDate = @GameRelease,
            @H_EDate = @EndSale

            DECLARE @NewPrice MONEY = (@Price - 10.00)

            EXEC insPlatformPriceHistory
            @G_Name = @GameName,
            @P_Name = @PlatformName,
            @H_Price = @NewPrice,
            @H_SDate = @GameRelease,
            @H_EDate = NULL
        END 
        ELSE 
        BEGIN 
            EXEC insPlatformPriceHistory
            @G_Name = @GameName,
            @P_Name = @PlatformName,
            @H_Price = @Price,
            @H_SDate = @GameRelease,
            @H_EDate = NULL
        END

        DELETE FROM @tempTable 
        WHERE GamePlatformID = @MIN_PK
    END 

    SET @GameRow = @GameRow - 1
END
GO

-- EXEC wrapper_insertPlatPrice
-- SELECT * FROM tblPlatform_Price_History
-- GO 

-- Restart:
-- DELETE FROM tblPlatform_Price_History
-- DBCC CHECKIDENT (tblPlatform_Price_History, RESEED, 0)

---------------------
-- Randomly generates interests per every gamer in the database 
-- 
CREATE PROCEDURE generateGamerInterests
AS 

DECLARE @Gamer_PK INT = (SELECT COUNT(*) FROM tblGAMER)
DECLARE @Keyword_Row INT = (SELECT COUNT(*) FROM tblKEYWORD)

WHILE @Gamer_PK > 0
BEGIN 
    DECLARE @Key_PK INT = (SELECT RAND() * @Keyword_Row + 1)

    DECLARE @F VARCHAR(50), @L VARCHAR(50), @DB DATE, @Gen VARCHAR(50), @Key VARCHAR(50)
    DECLARE @NumInterest INT = (SELECT RAND() * 5 + 1)
    SELECT 
            @F = (SELECT GamerFname FROM tblGAMER WHERE GamerID = @Gamer_PK),
            @L = (SELECT GamerLname FROM tblGAMER WHERE GamerID = @Gamer_PK),
            @DB = (SELECT GamerDOB FROM tblGAMER WHERE GamerID = @Gamer_PK),
            @Gen = (SELECT ge.GenderName FROM tblGAMER g
                JOIN tblGENDER AS ge ON ge.GenderID = g.GenderID
                WHERE GamerID = @Gamer_PK)
    WHILE @NumInterest > 0 
    BEGIN 
        DECLARE @InterestExist INT = (SELECT COUNT(*) FROM tblGAMER_INTEREST 
            WHERE GamerID = @Gamer_PK AND KeywordID = @Key_PK)
        WHILE @InterestExist > 0 
        BEGIN 
            SET @Key_PK = (SELECT RAND() * @Keyword_Row + 1)
            SET @InterestExist = (SELECT COUNT(*) FROM tblGAMER_INTEREST WHERE GamerID = @Gamer_PK AND KeywordID = @Key_PK)
        END

        SET @Key = (SELECT KeywordName FROM tblKEYWORD WHERE KeywordID = @Key_PK)

        EXEC InsertGAMER_INTEREST
        @Fname = @F,
        @Lname = @L,
        @DOB = @DB,
        @Gender = @Gen,
        @Keyword = @Key

        SET @Key_PK = (SELECT RAND() * @Keyword_Row + 1)
        
        SET @NumInterest = @NumInterest - 1
    END 

    SET @Gamer_PK = @Gamer_PK - 1
END 
GO 

-- EXEC generateGamerInterests
-- SELECT * FROM tblGAMER_INTEREST ORDER BY GamerID

-- Restart
-- DELETE FROM tblGAMER_INTEREST
-- DBCC CHECKIDENT (tblGAMER_INTEREST, RESEED, 0)





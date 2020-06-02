USE info430_gp10_VideoGame
GO 

----------------------------
-- SYNTHETIC TRANSACTIONS --
----------------------------

CREATE PROCEDURE generateOrders
@RUN INT 
AS 

DECLARE @Gamer_Row INT = (SELECT COUNT(*) FROM tblGAMER)
DECLARE @Game_Row INT = (SELECT COUNT(*) FROM tblGAME)
DECLARE @Plat_Row INT = (SELECT COUNT(*) FROM tblPlatform)

WHILE @RUN > 0
BEGIN 

    DECLARE @Gamer_PK INT = (SELECT RAND() * @Game_Row + 1)
    DECLARE @Game_PK INT = (SELECT RAND() * @Game_Row + 1)
    DECLARE @Plat_PK INT = (SELECT RAND() * @Plat_Row + 1)

    DECLARE @F VARCHAR(50), @L VARCHAR(50), @DB DATE, @Gen VARCHAR(50), @GN VARCHAR(50), @PN VARCHAR(50), @Q INT
    DECLARE @OrderItem INT = (SELECT RAND() * 5 + 1)
    SELECT 
            @F = (SELECT GamerFname FROM tblGAMER WHERE GamerID = @Gamer_PK),
            @L = (SELECT GamerLname FROM tblGAMER WHERE GamerID = @Gamer_PK),
            @DB = (SELECT GamerDOB FROM tblGAMER WHERE GamerID = @Gamer_PK),
            @Gen = (SELECT ge.GenderName FROM tblGAMER g
                JOIN tblGENDER AS ge ON ge.GenderID = g.GenderID
                WHERE GamerID = @Gamer_PK)
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

        SET @Game_PK = (SELECT RAND() * @Game_Row + 1)
        SET @Plat_PK = (SELECT RAND() * @Plat_Row + 1)
        
        SET @OrderItem = @OrderItem - 1
    END 

    DECLARE @PurDate DATE = (SELECT DATEADD(DD, -(SELECT RAND() * 365 * 10), GETDATE()))

    EXEC processCart 
    @Fname = @F,
    @Lname = @L,
    @DOB = @DB,
    @Gender = @Gen,
    @PurchaseDate = @PurDate

    SET @RUN = @RUN - 1
END 
GO 

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

EXEC wrapper_insertPlatPrice

SELECT * FROM tblPlatform_Price_History
GO 

-- Restart:
-- DELETE FROM tblPlatform_Price_History
-- DBCC CHECKIDENT (tblPlatform_Price_History, RESEED, 0)
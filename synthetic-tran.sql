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
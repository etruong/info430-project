USE info430_gp10_VideoGame
GO 

EXEC insertGame
@GName = 'Animal Crossing: New Horizons',
@GReleaseDate = 'March 20, 2020',
@GDescription = 'A very fun game where you capture animals while living amongst animals',
@PRateName = 'Everyone',
@PerName = 'Aerial',
@GeTName = 'Simulation'
GO 

EXEC insGamePlatform
@GN = 'Animal Crossing: New Horizons',
@PN = 'Switch',
@ReleaseDate = 'March 20, 2020'

EXEC insertGame
@GName = 'Animal Crossing: New Leaf',
@GReleaseDate = 'November 8, 2012',
@GDescription = 'A very fun game where you capture animals while living amongst animals',
@PRateName = 'Everyone',
@PerName = 'Aerial',
@GeTName = 'Simulation'
GO 

EXEC insGamePlatform
@GN = 'Animal Crossing: New Leaf',
@PN = '3DS',
@ReleaseDate = 'November 8, 2012'

EXEC insertGame
@GName = 'Animal Crossing: Wild World',
@GReleaseDate = 'November 23, 2005',
@GDescription = 'A very fun game where you capture animals while living amongst animals',
@PRateName = 'Everyone',
@PerName = 'Aerial',
@GeTName = 'Simulation'
GO 

EXEC insGamePlatform
@GN = 'Animal Crossing: Wild World',
@PN = '3DS',
@ReleaseDate = 'November 23, 2005'

EXEC insGamePlatform
@GN = 'Animal Crossing: Wild World',
@PN = 'Wii U',
@ReleaseDate = 'November 30, 2005'

DECLARE @TempTable TABLE (
    ID INT IDENTITY PRIMARY KEY,
    GameName VARCHAR(50),
    GameReleaseDate DATE,
    GameDesc VARCHAR(300),
    ParentRate VARCHAR(50),
    PerpName VARCHAR(50),
    GenreTypeName VARCHAR(50),
    Platform1 VARCHAR(50),
    Platform2 VARCHAR(50),
    Platform3 VARCHAR(50),
    Platform4 VARCHAR(50)
)

INSERT INTO @TempTable
    SELECT * FROM tempGameInfo

SELECT * FROM @TempTable
SELECT * FROM tblGENRE_TYPE

DECLARE @NumRow INT = (SELECT COUNT(*) FROM @TempTable)
WHILE @NumRow > 0
BEGIN 
    DECLARE @PK INT = (SELECT MAX(ID) FROM @TempTable)
    DECLARE @GN VARCHAR(50), @GReD DATE, @GDesc VARCHAR(600), @PRN VARCHAR(50), @PeN VARCHAR(50), @GTN VARCHAR(50)
    SELECT 
        @GN = (SELECT GameName FROM @TempTable WHERE ID = @PK), 
        @GReD = (SELECT GameReleaseDate FROM @TempTable WHERE ID = @PK), 
        @GDesc = (SELECT GameDesc FROM @TempTable WHERE ID = @PK), 
        @PRN = (SELECT ParentRate FROM @TempTable WHERE ID = @PK), 
        @PeN = (SELECT PerpName FROM @TempTable WHERE ID = @PK), 
        @GTN = (SELECT GenreTypeName FROM @TempTable WHERE ID = @PK)

    DECLARE @P1 VARCHAR(50), @P2 VARCHAR(50), @P3 VARCHAR(50), @P4 VARCHAR(50)
    SELECT 
        @P1 = (SELECT Platform1 FROM @TempTable WHERE ID = @PK), 
        @P2 = (SELECT Platform2 FROM @TempTable WHERE ID = @PK), 
        @P3 = (SELECT Platform3 FROM @TempTable WHERE ID = @PK), 
        @P4 = (SELECT Platform4 FROM @TempTable WHERE ID = @PK)

    EXEC insertGame
    @GName = @GN,
    @GReleaseDate = @GReD,
    @GDescription = @GDesc,
    @PRateName = @PRN,
    @PerName = @PeN,
    @GeTName = @GTN

    IF @P1 IS NOT NULL 
    BEGIN 
        EXEC insGamePlatform
        @GN = @GN,
        @PN = @P1,
        @ReleaseDate = @GReD
    END 

    DECLARE @RAND_DATE DATE;
    IF @P2 IS NOT NULL 
    BEGIN 
        SET @RAND_DATE = (SELECT DATEADD(DD, (SELECT RAND() * 10), @GReD))
        EXEC insGamePlatform
        @GN = @GN,
        @PN = @P2,
        @ReleaseDate = @RAND_DATE
    END 

    IF @P3 IS NOT NULL 
    BEGIN 
        SET @RAND_DATE = (SELECT DATEADD(DD, (SELECT RAND() * 10), @GReD))
        EXEC insGamePlatform
        @GN = @GN,
        @PN = @P3,
        @ReleaseDate = @RAND_DATE
    END 

    IF @P4 IS NOT NULL 
    BEGIN 
        SET @RAND_DATE = (SELECT DATEADD(DD, (SELECT RAND() * 10), @GReD))
        EXEC insGamePlatform
        @GN = @GN,
        @PN = @P4,
        @ReleaseDate = @RAND_DATE
    END 

    DELETE FROM @TempTable
    WHERE ID = @PK

    SET @NumRow = @NumRow - 1
END

-- Restart?
-- DELETE FROM tblGamePlatform
-- DELETE FROM tblGame
-- DBCC CHECKIDENT (tblGamePlatform, RESEED, 0)
-- DBCC CHECKIDENT (tblGame, RESEED, 0)

SELECT * FROM tblPublisher
SELECT * FROM tblGAME

--insert data into bridge tables by Andi-- 

DECLARE @games INT = (SELECT COUNT(*) FROM tblGAME)
DECLARE @Dev INT, @Key INT, @Lan INT, @Reg INT, @Pub INT, @Sales Money

While @games > 0
BEGIN

SET @Dev = FLOOR(RAND()*(6))+1
SET @Key = FLOOR(RAND()*(31))+1
SET @Lan = FLOOR(RAND()*(5))+1
SET @Reg = FLOOR(RAND()*(5))+1
SET @Pub = FLOOR(RAND()*(3))+1

SET @Sales = CONVERT(MONEY,RAND()*1500000000)

INSERT INTO tblDEVELOPER_GAME 
(DeveloperID,
GameID)
VALUES
(@Dev,
@games)

INSERT INTO tblGAME_KEYWORD 
(KeywordID,
GameID)
VALUES
(@Key,
@games)

INSERT INTO tblGAME_LANGUAGE
(LanguageID,
GameID)
VALUES
(@Lan,
@games)

INSERT INTO tblGAME_REGION_SALES
(RegionID,
GameID,
GameSalesNum)
VALUES
(@Reg,
@games,
@Sales)

INSERT INTO tblGamePublisher 
(PublisherID,
GameID)
VALUES
(@Pub,
@games)

SET @games = @games - 1
END

GO

SELECT * FROM [dbo].[tblGAME_KEYWORD]
SELECT * FROM [dbo].[tblGAME_LANGUAGE]
SELECT * FROM [dbo].[tblGAME_REGION_SALES]
SELECT * FROM [dbo].[tblGamePublisher]


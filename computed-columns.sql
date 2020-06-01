USE info430_gp10_VideoGame
GO

----------------------
-- COMPUTED COLUMNS --
----------------------

---------------------------
-- Creator: Elisa Truong --
---------------------------

-- HistoryCurrent for tblPlatform_Price_History
CREATE FUNCTION isPriceCurrent(@Start DATE, @End DATE)
RETURNS BIT 
AS
BEGIN
    DECLARE @RET BIT = 0
    DECLARE @CurrentDate DATE = (SELECT GETDATE())
    IF (@CurrentDate BETWEEN @START AND @END)
    BEGIN 
        SET @RET = 1
    END 
    RETURN @RET
END
GO 

ALTER TABLE tblPlatform_Price_History
ADD HistoryCurrent AS dbo.isPriceCurrent(HistoryStart, HistoryEnd)
GO

-- PriceRange for tblGAME
CREATE FUNCTION PriceRange(@GameID INT)
RETURNS VARCHAR(50)
AS 
BEGIN 
    DECLARE @MAX MONEY = (SELECT TOP 1 CurrentPrice FROM tblGamePlatform WHERE GameID = @GameID ORDER BY CurrentPrice DESC)
    DECLARE @MIN MONEY = (SELECT TOP 1 CurrentPrice FROM tblGamePlatform WHERE GameID = @GameID ORDER BY CurrentPrice ASC)
    DECLARE @RET VARCHAR(50) = (SELECT CONCAT(@MAX, ' - ', @MIN))
    RETURN @RET
END
GO 

CREATE FUNCTION AverageReview(@GameID INT)
RETURNS FLOAT
AS
BEGIN
	RETURN (SELECT AVG(ReviewRating)
	FROM tblGAME G
	JOIN tblORDER_GAME OG ON G.GameID = OG.GameID
	JOIN tblREVIEW R ON R.OrderGameID = OG.OrderGameID
	WHERE G.GameID = @GameID
	)
END
GO

CREATE FUNCTION LanguageNum(@GameID INT)
RETURNS INT
AS
BEGIN
	RETURN (SELECT COUNT(GameLanguageID)
	FROM tblGAME G
	JOIN tblGAME_LANGUAGE GL ON G.GameID = GL.GameID
	WHERE G.GameID = @GameID
	)
END
GO

ALTER TABLE tblGAME 
ADD PriceRange AS dbo.PriceRange(GameID)
GO

---------------------------
-- Creator: Marcus Huang --
---------------------------

--NumOfGamesBought (Gamer Table) � must be unique
CREATE FUNCTION numGamesBought(@GamerID INT)
RETURNS INT
AS
BEGIN
	DECLARE @RET INT = (SELECT COUNT(DISTINCT OG.GameID)
									FROM tblORDER_GAME OG
										JOIN tblORDER O ON OG.OrderID = O.OrderID
										JOIN tblGAMER G ON O.GamerID = G.GamerID
										WHERE O.GamerID = @GamerID)
	RETURN @RET			
END
GO

ALTER TABLE tblGAMER
ADD NumBought 
AS dbo.numGamesBought(GamerID)
GO

--GameCurrentPrice (GamePlatform table)
CREATE FUNCTION gameCurrentPrice(@GamePlatformID INT)
RETURNS INT
AS
BEGIN
	DECLARE @RET INT = (SELECT PPH.HistoryPrice
						FROM tblGamePlatform GP
						JOIN tblPlatform_Price_History PPH ON GP.GamePlatformID = PPH.GamePlatformID
						WHERE HistoryCurrent = 1	
	)
	RETURN @RET
END
GO

ALTER TABLE tblGamePlatform
ADD CurrentPrice
AS dbo.gameCurrentPrice(GamePlatformID)
GO

------------------------
-- Creator: Angel Lin --
------------------------

-- Computed Column: Age of Gamer (Gamer Table) --
ALTER TABLE tblGAMER
ADD GamerAge
AS (CONVERT(INT,CONVERT(CHAR(8),GETDATE(),112))-CONVERT(CHAR(8),GamerDOB,112))/10000 
GO

-- Computed Column: Most Recently Bought Game (Gamer Table) --
CREATE FUNCTION recentBoughtGame(@PK INT)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @RET VARCHAR(50) = 
		(SELECT TOP 1 G.GameName 
		 FROM tblGame AS G 
			JOIN tblOrder_Game AS OG ON G.GameID = OG.GameID
			JOIN tblOrder AS O ON OG.OrderID = O.OrderID
			JOIN tblGamer AS GR ON O.GamerID = GR.GamerID
		 WHERE GR.GamerID = @PK
		 ORDER BY O.OrderDate DESC)
	RETURN @RET
END
GO

-----------------------
-- Creator: Andi Ren --
-----------------------

ALTER TABLE tblGAMER
ADD recentBoughtGame AS dbo.recentBoughtGame(GamerID)
GO

ALTER TABLE tblGAME
ADD AvgReview AS dbo.AverageReview(GameID)
GO

ALTER TABLE tblGAME
ADD GameNumLanguagesSupport AS dbo.LanguageNum(GameID)
GO

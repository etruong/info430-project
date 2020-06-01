USE info430_gp10_VideoGame
GO

----------------------
-- COMPUTED COLUMNS --
----------------------

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

ALTER TABLE tblGAME 
ADD PriceRange AS dbo.PriceRange(GameID)
GO

------- Marcus
--NumOfGamesBought (Gamer Table) — must be unique
CREATE FUNCTION numGamesBought(@GamerID INT)
RETURNS INT
AS
BEGIN
	DECLARE @GAMESINORDER INT = (SELECT COUNT(DISTINCT OG.GameID)
									FROM tblORDER_GAME OG
										JOIN tblORDER O ON OG.OrderID = O.OrderID
										JOIN tblGAMER G ON O.GamerID = G.GamerID
										WHERE O.GamerID = @GamerID)
	DECLARE @CURRENTNUMGAMES INT = (SELECT G.NumBought
										FROM tblGAMER G)
	DECLARE @RET INT = (SELECT @GAMESINORDER + @CURRENTNUMGAMES)
	RETURN @RET			
END
GO

ALTER TABLE tblGAMER
ADD NumBought AS dbo.numGamesBought(@GamerID)
GO

--GameCurrentPrice (GamePlatform table)

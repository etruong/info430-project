USE info430_gp10_VideoGame
GO

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

ALTER TABLE tblGAMER
ADD recentBoughtGame AS dbo.recentBoughtGame(GamerID)
GO
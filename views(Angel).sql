USE info430_gp10_VideoGame
GO

-- Create View: Top 3 Platforms -- 
CREATE VIEW vTop3Platforms
AS 
SELECT TOP 3 P.PlatformName, COUNT(GP.GamePlatformID) AS NumGamePlatform,
DENSE_RANK() OVER (ORDER BY COUNT(GP.GamePlatformID) DESC) AS RankPopularPlatform
FROM tblPlatform AS P 
	JOIN tblGamePlatform AS GP ON P.PlatformID = GP.PlatformID
GROUP BY P.PlatformName
GO

-- Create View: Top Developers -- 
CREATE VIEW vTop3Developers
AS
SELECT TOP 3 D.DeveloperName, SUM (OG.GamePrice) AS GameRevenue,
DENSE_RANK() OVER (ORDER BY SUM (OG.GamePrice) DESC) AS RankGameRevenue
FROM tblDeveloper AS D
	JOIN tblDeveloper_Game AS DG ON D.DeveloperID = DG.DeveloperID
	JOIN tblGame AS G ON DG.GameID = G.GameID
	JOIN tblOrder_Game AS OG ON G.GameID = OG.GameID 
GROUP BY D.DeveloperName
GO


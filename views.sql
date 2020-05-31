USE info430_gp10_VideoGame
GO 

CREATE VIEW tblGAME_INFO 
AS 
SELECT
    g.GameName, 
    g.GameDescription, 
    gt.GenreTypeName AS Genre, 
    p.PerpName AS GamePerspective,
    pr.ParentRateName AS ParentRating,
    g.GameReleaseDate,
    AVG(r.ReviewRating) AS AverageRating,
    SUM(grs.GameSalesNum) AS GlobalTotalSales
FROM tblGAME AS g 
    JOIN tblGENRE_TYPE AS gt ON g.GenreTypeID = gt.GenreTypeID
    JOIN tblPERSPECTIVE AS p ON p.PerpID = g.PerpID
    JOIN tblPARENT_RATE AS pr ON pr.ParentRateID = g.ParentRateID
    JOIN tblORDER_GAME AS og ON og.GameID = g.GameID
    JOIN tblREVIEW AS r ON r.OrderGameID = og.OrderGameID
    JOIN tblGAME_REGION_SALES AS grs ON grs.GameID = g.GameID
GROUP BY
    g.GameName, 
    g.GameDescription, 
    gt.GenreTypeName, 
    p.PerpName,
    pr.ParentRateName,
    g.GameReleaseDate
GO

CREATE VIEW tblGAME_CURRENT_PRICE 
AS 
SELECT g.GameName, p.PlatformName, pph.HistoryPrice
FROM tblGAME AS g 
    JOIN tblGamePlatform AS gp ON gp.GameID = g.GameID
    JOIN tblPlatform AS p ON p.PlatformID = gp.PlatformID
    JOIN tblPlatform_Price_History AS pph ON pph.GamePlatformID = gp.GamePlatformID
WHERE pph.HistoryCurrent = 'true'
GO

CREATE VIEW tblMOST_POPULAR_BY_AGE
AS 
SELECT (DATEDIFF(DD, g.GamerDOB, GETDATE()) / 365.25) AS Age
FROM tblGAMER AS g
GO 

--SELECT 
-- Num ordered
-- Popular Game
-- Popular Genre
-- Popular Perspective



CREATE VIEW topGameByGender
AS
SELECT G.GameName, 
	GT.GenreTypeName, 
	GE.GenderName


FROM tblGAME G
	JOIN tblGENRE_TYPE GT ON G.GenreTypeID = GT.GenreTypeID
	JOIN tblGAME_KEYWORD GK ON G.GameID = GK.GameID
	JOIN tblKEYWORD K ON GK.KeywordID = K.KeywordID
	JOIN tblGAMER_INTEREST GI ON K.KeywordID = GI.KeywordID
	JOIN tblGAMER GA ON GI.GamerID = GA.GamerID
	JOIN tblGENDER GE ON GA.GenderID = GE.GenderID

GROUP BY G.GameName, 
	GT.GenreTypeName, 
	GE.GenderName


CREATE VIEW topGameByName
AS 
SELECT G.GameName, 
	GT.GenreTypeName,
	GA.GamerFname,
	GA.GamerLname
FROM tblGAME G
	JOIN tblKEYWORD K ON GK.KeywordID = K.KeywordID
	JOIN tblGAMER_INTEREST GI ON K.KeywordID = GI.KeywordID
	JOIN tblGAMER GA ON GI.GamerID = GA.GamerID


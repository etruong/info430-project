USE info430_gp10_VideoGame
GO 

--------------------
-- BUSINESS RULES --
--------------------

---------------------------
-- Creator: Elisa Truong --
---------------------------

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
SELECT g.GamerAge, SUM(og.OrderGameQty) AS NumGameOrdered, sq1.GenreTypeName, sq2.PerpName
FROM tblGAMER AS g
    JOIN tblOrder AS o ON o.GamerID = g.GamerID
    JOIN tblORDER_GAME AS og ON og.OrderID = o.OrderID
    JOIN (
        SELECT g.GamerAge, gt.GenreTypeName, SUM(og.OrderGameQty) AS NumOrder, 
            RANK() OVER (PARTITION BY gt.GenreTypeName ORDER BY SUM(og.OrderGameQty)) AS GenreRank
        FROM tblGAMER AS g 
            JOIN tblOrder AS o ON o.GamerID = g.GamerID
            JOIN tblORDER_GAME AS og ON og.OrderID = o.OrderID
            JOIN tblGAME AS ga ON ga.GameID = og.GameID 
            JOIN tblGENRE_TYPE AS gt ON gt.GenreTypeID = ga.GenreTypeID
        GROUP BY g.GamerAge, gt.GenreTypeName
    ) AS sq1 ON sq1.GamerAge = g.GamerAge 
    JOIN (
        SELECT g.GamerAge, p.PerpName, SUM(og.OrderGameQty) AS NumOrder, 
            RANK() OVER (PARTITION BY p.PerpName ORDER BY SUM(og.OrderGameQty)) AS PerpRank
        FROM tblGAMER AS g 
            JOIN tblOrder AS o ON o.GamerID = g.GamerID
            JOIN tblORDER_GAME AS og ON og.OrderID = o.OrderID
            JOIN tblGAME AS ga ON ga.GameID = og.GameID
            JOIN tblPERSPECTIVE AS p ON p.PerpID = ga.PerpID
        GROUP BY g.GamerAge, p.PerpName
    ) AS sq2 ON sq2.GamerAge = g.GamerAge
WHERE 
    PerpRank = 1 AND 
    GenreRank = 1
GROUP BY g.GamerAge, sq1.GenreTypeName, sq2.PerpName
GO 

---------------------------
-- Creator: Marcus Huang --
---------------------------

-- Most popular games by gender
CREATE VIEW topGameByGender
AS
SELECT G.GameName, 
	GT.GenreTypeName, 
	GE.GenderName,
	SUM(OG.OrderGameQty) AS NumGameOrdered,
	RANK() OVER(PARTITION BY GE.GenderName ORDER BY SUM(OG.OrderGameQty)) AS GenderRank
FROM tblGAME G
	JOIN tblGENRE_TYPE GT ON G.GenreTypeID = GT.GenreTypeID
	JOIN tblGAME_KEYWORD GK ON G.GameID = GK.GameID
	JOIN tblKEYWORD K ON GK.KeywordID = K.KeywordID
	JOIN tblGAMER_INTEREST GI ON K.KeywordID = GI.KeywordID
	JOIN tblGAMER GA ON GI.GamerID = GA.GamerID
	JOIN tblGENDER GE ON GA.GenderID = GE.GenderID
	JOIN tblORDER_GAME OG ON G.GameID = OG.GameID
GROUP BY G.GameName, 
	GT.GenreTypeName, 
	GE.GenderName
GO

-- Most popular games by name (specifically Kyles)
CREATE VIEW topGameByName
AS 
SELECT G.GameName, 
	GT.GenreTypeName,
	GA.GamerFname,
	GA.GamerLname,
	SUM(OG.OrderGameQty) AS NumGameOrdered,
	RANK() OVER(ORDER BY SUM(OG.OrderGameQty)) AS NameRank
FROM tblGAME G
	JOIN tblGENRE_TYPE GT ON G.GenreTypeID = GT.GenreTypeID
	JOIN tblGAME_KEYWORD GK ON G.GameID = GK.GameID
	JOIN tblKEYWORD K ON GK.KeywordID = K.KeywordID
	JOIN tblGAMER_INTEREST GI ON K.KeywordID = GI.KeywordID
	JOIN tblGAMER GA ON GI.GamerID = GA.GamerID
	JOIN tblORDER_GAME OG ON G.GameID = OG.GameID
WHERE GA.GamerFname = 'Kyle'
GROUP BY G.GameName, 
	GT.GenreTypeName,
	GA.GamerFname,
	GA.GamerLname
GO

------------------------
-- Creator: Angel Lin --
------------------------

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

-----------------------
-- Creator: Andi Ren --
-----------------------

CREATE VIEW tblTOP10_POP_GAME
AS
SELECT TOP 10 G.GameID, G.GameName, COUNT(OG.GameID) AS totalOrderNum
FROM tblGAME G
JOIN tblORDER_GAME OG ON G.GameID = OG.GameID
GROUP BY G.GameID, G.GameName
ORDER BY COUNT(OG.GameID)
GO

--TOP Regions sales
CREATE VIEW tblTOP_3_REGION_SALES
AS
SELECT TOP 3 R.RegionID, R.RegionName, SUM(GRS.GameSalesNum) AS totalSales
FROM tblREGION R
JOIN tblGAME_REGION_SALES GRS ON R.RegionID = GRS.RegionID
GROUP BY R.RegionID, R.RegionName
ORDER BY SUM(GRS.GameSalesNum)

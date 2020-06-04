USE Proj_A10
GO 
--------------------
-- BUSINESS RULES --
--------------------

---------------------------
-- Creator: Elisa Truong --
---------------------------

-- Prohibits childern underage from purchasing a 
-- game not within their parental guidance
CREATE FUNCTION checkGamerMature()
RETURNS INT 
AS 
BEGIN 
    DECLARE @RET INT = 0
    -- Everyone 10+
    IF EXISTS(
        SELECT g.GamerID, g.GamerDOB
        FROM tblGAMER AS g 
            JOIN tblORDER AS o ON o.GamerID = g.GamerID 
            JOIN tblORDER_GAME AS og ON og.OrderID = o.OrderID
            JOIN tblGAME AS game ON game.GameID = og.GameID 
            JOIN tblPARENT_RATE AS pr ON pr.ParentRateID = game.ParentRateID
        WHERE (SELECT FLOOR(DATEDIFF(DAY, g.GamerDOB, GETDATE()) / 365.25)) < 10
            AND pr.ParentRateName LIKE '%Everyone 10+%'
    )
        SET @RET = 1 
    
    -- Teen (13+)
    IF EXISTS(
        SELECT g.GamerID, g.GamerDOB
        FROM tblGAMER AS g 
            JOIN tblORDER AS o ON o.GamerID = g.GamerID 
            JOIN tblORDER_GAME AS og ON og.OrderID = o.OrderID
            JOIN tblGAME AS game ON game.GameID = og.GameID 
            JOIN tblPARENT_RATE AS pr ON pr.ParentRateID = game.ParentRateID
        WHERE (SELECT FLOOR(DATEDIFF(DAY, g.GamerDOB, GETDATE()) / 365.25)) < 13
            AND pr.ParentRateName LIKE '%Teen%'
    )
        SET @RET = 1

    -- Mature (17+)
    IF EXISTS(
        SELECT g.GamerID, g.GamerDOB
        FROM tblGAMER AS g 
            JOIN tblORDER AS o ON o.GamerID = g.GamerID 
            JOIN tblORDER_GAME AS og ON og.OrderID = o.OrderID
            JOIN tblGAME AS game ON game.GameID = og.GameID 
            JOIN tblPARENT_RATE AS pr ON pr.ParentRateID = game.ParentRateID
        WHERE (SELECT FLOOR(DATEDIFF(DAY, g.GamerDOB, GETDATE()) / 365.25)) < 17
            AND pr.ParentRateName LIKE '%Mature+%'
    )
        SET @RET = 1

    -- Adult (18+)
    IF EXISTS(
        SELECT g.GamerID, g.GamerDOB
        FROM tblGAMER AS g 
            JOIN tblORDER AS o ON o.GamerID = g.GamerID 
            JOIN tblORDER_GAME AS og ON og.OrderID = o.OrderID
            JOIN tblGAME AS game ON game.GameID = og.GameID 
            JOIN tblPARENT_RATE AS pr ON pr.ParentRateID = game.ParentRateID
        WHERE (SELECT FLOOR(DATEDIFF(DAY, g.GamerDOB, GETDATE()) / 365.25)) < 18
            AND pr.ParentRateName LIKE '%Adult%'
    )
        SET @RET = 1
    RETURN @RET
END
GO

ALTER TABLE tblORDER_GAME 
ADD CONSTRAINT CheckGamerMaturity 
CHECK(dbo.checkGamerMature() = 0)
GO 

-- Business Rule: Children under age of 12 yo cannot buy games with keywords 'fighting' or 'guns' or 'shooting'
CREATE FUNCTION fn_LimitChildrenGameType()
RETURNS INT 
AS 
BEGIN 
    DECLARE @RET INT = 0 
    IF EXISTS (
        SELECT * FROM tblGAMER AS g 
            JOIN tblORDER AS o ON o.GamerID = g.GamerID
            JOIN tblORDER_GAME AS og ON og.OrderID = o.OrderID 
            JOIN tblGame AS ga ON ga.GameID = og.GameID
            JOIN tblGAME_KEYWORD AS gk ON gk.GameID = ga.GameID 
            JOIN tblKEYWORD AS k ON k.KeywordID = gk.KeywordID
        WHERE (SELECT FLOOR(DATEDIFF(DAY, g.GamerDOB, GETDATE()) / 365.25)) < 12 
        AND k.KeywordName IN ('Fighting', 'Guns', 'Shooting', 'Violence')
    )
    BEGIN 
        SET @RET = 1
    END
    RETURN @RET
END 
GO 

ALTER TABLE tblORDER_GAME 
ADD CONSTRAINT LimitChildGameType 
CHECK(dbo.fn_LimitChildrenGameType() = 0)
GO 

---------------------------
-- Creator: Marcus Huang --
---------------------------

-- Price cannot be negative (Order total)
CREATE FUNCTION fn_noNegativeOrderTotal()
RETURNS INT 
AS 
BEGIN
	DECLARE @RET INT = 0
	IF EXISTS(
		SELECT * FROM tblORDER O
		WHERE O.OrderTotal < 0
	)
	BEGIN
		SET @RET = 1
	END
	RETURN @RET
END
GO

ALTER TABLE tblORDER
ADD CONSTRAINT noNegativeOrderTotal
CHECK (dbo.fn_noNegativeOrderTotal() = 0)
GO

-- Price cannot be negative (OrderGameSubprice)
CREATE FUNCTION fn_noNegativeOrderGameSubprice()
RETURNS INT 
AS 
BEGIN
	DECLARE @RET INT = 0
	IF EXISTS(
		SELECT * FROM tblORDER_GAME OG
		WHERE OG.OrderGameSubprice < 0
	)
	BEGIN
		SET @RET = 1
	END
	RETURN @RET
END
GO

ALTER TABLE tblORDER_GAME
ADD CONSTRAINT noNegativeOrderGameSubprice
CHECK (dbo.fn_noNegativeOrderGameSubprice() = 0)
GO

------------------------
-- Creator: Angel Lin --
------------------------

-- Business rule: Cannot make more than 3 reviews per customer -- 
CREATE FUNCTION fn_limit3Reviews()
RETURNS INT 
AS
BEGIN
	DECLARE @RET INT = 0
	IF EXISTS (
		SELECT O.GamerID, COUNT(R.ReviewID) AS NumReview FROM tblGAMER AS G 
            JOIN tblORDER AS O ON O.GamerID = G.GamerID
            JOIN tblORDER_GAME AS OG ON OG.OrderID = O.OrderID
			JOIN tblREVIEW AS R ON R.OrderGameID = OG.OrderGameID
        GROUP BY O.GamerID
        HAVING COUNT(R.ReviewID) > 3
	)
	BEGIN 
		SET @RET = 1
	END
	RETURN @RET
END 
GO

ALTER TABLE tblREVIEW
ADD CONSTRAINT limit3Reviews
CHECK(dbo.fn_limit3Reviews() = 0)
GO

-- Business rule: Quantity Cannot be negative in OrderGame Table -- 
ALTER TABLE tblORDER_GAME
ADD CONSTRAINT check_order_positive CHECK (OrderGameQty > 0);

-----------------------
-- Creator: Andi Ren --
-----------------------

ALTER TABLE [dbo].[tblORDER]
ADD CONSTRAINT OrderDate CHECK (OrderDate <= GetDate());

ALTER TABLE [dbo].[tblReview]
ADD CONSTRAINT ReviewDate CHECK (ReviewDate <= GetDate());
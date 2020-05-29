USE info430_gp10_VideoGame
GO 

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
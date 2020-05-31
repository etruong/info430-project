USE info430_gp10_VideoGame
GO

-- Business rule: Cannot make more than 3 reviews per customer -- 
CREATE FUNCTION fn_limit3Reviews(@PK INT)
RETURNS INT 
AS
BEGIN
	DECLARE @RET INT = 0
	IF EXISTS (
		SELECT * FROM tblGAMER AS G 
            JOIN tblORDER AS O ON O.GamerID = G.GamerID
            JOIN tblORDER_GAME AS OG ON OG.OrderID = O.OrderID
			JOIN tblREVIEW AS R ON R.OrderGameID = OG.OrderGameID
		WHERE G.GamerID = @PK
		HAVING COUNT(*) > 3
	)
	BEGIN 
		SET @RET = 1
	END
	RETURN @RET
END 
GO

ALTER TABLE tblGAMER
ADD CONSTRAINT limit3Reviews
CHECK(dbo.fn_limit3Reviews() = 0)
GO

-- Business rule: Quantity Cannot be negative in OrderGame Table -- 
ALTER TABLE tblORDER_GAME
ADD CONSTRAINT check_order_positive CHECK (OrderGameQty> 0);

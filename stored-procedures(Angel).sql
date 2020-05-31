USE info430_gp10_VideoGame
GO

-- Insert Procedure: tblPlatformPriceHistory --
ALTER PROCEDURE getGamePlatformID
@GN VARCHAR(50),
@PN VARCHAR(50),
@GPID INT OUTPUT
As

DECLARE @G_ID INT, @P_ID INT

EXEC getGameID
@GName = @GN,
@GID = @G_ID OUTPUT
IF @G_ID IS NULL
BEGIN 
	RAISERROR('Game ID cannot be null!', 11, 1)
	RETURN
END

EXEC getPlatformID
@PName = @PN,
@PID = @P_ID OUTPUT
IF @P_ID IS NULL
BEGIN 
	RAISERROR('Platform ID cannot be null!', 11, 1)
	RETURN
END

SET @GPID = (SELECT GamePlatformID FROM tblGamePlatform
			 WHERE GameID = @G_ID
			 AND PlatformID = @P_ID)

GO

ALTER PROCEDURE insPlatformPriceHistory
@G_Name VARCHAR(50),
@P_Name VARCHAR(50),
@H_Price MONEY,
@H_SDate DATE,
@H_EDate DATE
AS

DECLARE @GP_ID INT

EXEC getGamePlatformID
@GN = @G_Name,
@PN = @P_Name,
@GPID = @GP_ID OUTPUT
IF @GP_ID IS NULL
BEGIN 
    RAISERROR('Game Platform ID cannot be null!', 11, 1)
    RETURN
END

BEGIN TRAN addPlatformPriceHistory
		INSERT INTO tblPlatform_Price_History(GamePlatformID, HistoryPrice, HistoryStart, HistoryEnd)
		VALUES (@GP_ID, @H_Price, @H_SDate, @H_EDate)

		IF @@ERROR<> 0 
		BEGIN 
			PRINT('Ran into error while adding item to platform price history!')
			ROLLBACK TRAN addPlatformPriceHistory
		END
		ELSE 
			COMMIT TRAN addPlatformPriceHistory
GO 

-- Insert Procedure: tblGamePlatform --
CREATE PROCEDURE insGamePlatform
@GN VARCHAR(50),
@PN VARCHAR(50),
@ReleaseDate DATE
AS

DECLARE @G_ID INT, @P_ID INT

EXEC getGameID
@GName = @GN,
@GID = @G_ID OUTPUT
IF @G_ID IS NULL
BEGIN 
	RAISERROR('Game ID cannot be null!', 11, 1)
	RETURN
END

EXEC getPlatformID
@PName = @PN,
@PID = @P_ID OUTPUT
IF @P_ID IS NULL
BEGIN 
	RAISERROR('Platform ID cannot be null!', 11, 1)
	RETURN
END

BEGIN TRAN addToGamePlatform
	INSERT INTO tblGamePlatform(GameID, PlatformID, PlatformReleaseDate)
	VALUES (@G_ID, @P_ID, @ReleaseDate)

	IF @@ERROR <> 0
	BEGIN
		PRINT('Ran into error while adding item to Game Platform!')
		ROLLBACK TRAN addToGamePlatform
	END
	ELSE 
		COMMIT TRAN addToGamePlatform
GO


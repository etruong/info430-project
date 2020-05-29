DROP DATABASE IF EXISTS info430_gp10_VideoGame
GO

CREATE DATABASE info430_gp10_VideoGame
GO

USE info430_gp10_VideoGame
GO 

-- [ Create Look up tables ] --
CREATE TABLE tblPERSPECTIVE
    (PerpID INT IDENTITY(1,1) primary key,
    PerpName varchar(20),
    PerpDescription varchar(200))
GO

CREATE TABLE tblLANGUAGE
    (LanguageID INT IDENTITY(1,1) primary key,
    LanguageName varchar(50),
    LanguageDescription varchar(600))
GO

CREATE TABLE tblKEYWORD(
    KeywordID INT PRIMARY KEY IDENTITY NOT NULL,
    KeywordName VARCHAR(100) NOT NULL
)
GO

CREATE TABLE tblREGION (
	RegionID INT IDENTITY(1,1) PRIMARY KEY,
	RegionName VARCHAR(20),
	RegionDescription VARCHAR(50)
);
GO

CREATE TABLE tblGENRE_TYPE(
	GenreTypeID INT IDENTITY(1,1) PRIMARY KEY,
	GenreTypeName VARCHAR(20),
	GenreTypeDescription VARCHAR(50)
);
GO

CREATE TABLE tblPARENT_RATE(
	ParentRateID INT IDENTITY(1,1) PRIMARY KEY,
	ParentRateName VARCHAR(20),
	ParentRateDescription VARCHAR(200)
);
GO

CREATE TABLE dbo.tblPlatform (
	PlatformID int PRIMARY KEY IDENTITY(1,1) Not Null,
	PlatformName varchar(250) Not Null,
	PlatformDescription	varchar(250) Not Null
)
GO

CREATE TABLE dbo.tblPublisher (
	PublisherID	int	PRIMARY KEY IDENTITY(1,1) Not Null,
	PublisherName varchar(250) Not Null,
	PublisherDescription varchar(250) Not Null
)
GO

CREATE TABLE tblDEVELOPER(
    DeveloperID INT IDENTITY(1,1) primary key,
    DeveloperName varchar(60),
    DeveloperDescription varchar(600)
)
GO

CREATE TABLE tblGENDER(
    GenderID  INT PRIMARY KEY IDENTITY NOT NULL,
    GenderName VARCHAR(50) NOT NULL 
)
GO

CREATE TABLE tblGAMER(
    GamerID INT PRIMARY KEY IDENTITY NOT NULL,
    GamerFname VARCHAR(50) NOT NULL,
    GamerLname VARCHAR(50) NOT NULL,
    GamerDOB DATE NOT NULL,
    GamerUsername VARCHAR(50) NOT NULL,
    -- GamerAge INT NOT NULL        (Computed)
    -- MostRecentBought VARCHAR(50) (Computed)
    -- NumGames INT                 (Computed)
    GenderID INT FOREIGN KEY REFERENCES tblGENDER(GenderID)
)
GO

-- [ Populate Look up tables ] -- 

INSERT INTO tblGENRE_TYPE(GenreTypeName, GenreTypeDescription)
VALUES 
	('Action', 'Players are in control of the action'),
	('Adventure', 'Players interact with their environment and other characters'),
	('Role-Playing', 'Featured medieval or fantasy settings'),
	('Simulation', 'Designed to emulate real or fictional reality'),
	('Strategy', 'Gives platers a godlike access to the world and its resources')
GO

INSERT INTO tblPARENT_RATE(ParentRateName, ParentRateDescription)
VALUES 
	('Everyone', 'May contain cartoon, fantacy and mild violence'),
	('Everyone 10+', 'May contain more cartoon, fantacy and minimal suggestive themes'),
	('Teen', 'May contain violence, suggestive themes and use of strong language'),
	('Mature 17+', 'May contain intensive violence, blood, gore and sexual content'),
	('Adults Only 18+', 'May contain prolonged scenes of intense violence and sexual content'),
	('Rating Pending', 'Not yet assigned a final rating')
GO

INSERT INTO tblREGION(RegionName, RegionDescription)
VALUES 
	('NA', 'North America'),
	('EU', 'Europe'),
	('JP', 'Japan'),
	('Other', 'The rest of the world'),
	('Global', 'Total worldwide')
GO

INSERT INTO tblKEYWORD(KeywordName)
VALUES
    ('Multiplayer'),
    ('Single Player'),
    ('Cooperative'),
    ('Shooter'),
    ('Farming'),
    ('Fantasy'),
    ('Fighting'),
    ('Sport')
GO

INSERT INTO tblDEVELOPER(DeveloperName, DeveloperDescription)
VALUES 
    ('Ubisoft', 'One of the legendary top game developers in the world that was founded in France in 1986 by Guillemot brothers. It published a dozen of superhero-based games but its main projects are Prince of Persia, Assassin�s Creed, Far Cry, and Tom Clancy�s series. '),
    ('Electronic Arts', 'Since 1982 Electronic Arts produces masterpieces in the gaming. Their last release of the FIFA series just blew the minds of millions of fans around the world. A lot of gamers associate EA with the sports simulators due to the popularity of FIFA, NHL, NFL, and MMA. However, there are many other extremely popular videogames the company has published in the last decade. Just recall The Sims, Crysis, Medal of Honor, and Mass Effect. '),
    ('Activision Blizzard', 'The company was established after the merge of Activision and Vivendi Games in 2008. Activision Blizzard is one of the three largest game development studios in the U.S. operating several smaller subsidiaries like Infinity Wards and Treyarch. Call of Duty, Warcraft, Starcraft, Diablo, Guitar Hero are just a few of the great games Activision Blizzard has created.'),
    ('Sony Computer Entertainment', 'Also known as Sony Interactive or, simple, Sony Entertainment, the company managed to become the most valuable game development studio so far. Concentrated on the technologies and innovation, Sony created a revolutionary Playstation console system. Today, such popular projects like God of War, Gran or Turismo Sport are produced by SIE Worldwide Studios (a group of video game developers owned by Sony Interactive Entertainment), which include, for instance, Guerilla Games and Insomniac Games.'),
    ('Microsoft  Studios', 'An exclusive publisher to Xbox and Windows, Microsoft also produces its own videogames. As a subsidiary of Microsoft, the company acts as a designer for Windows, Steam, and all Xbox versions. For example, it assisted in creating Gears of War, Halo, Minecraft, and other prominent names. '),
    ('Namco Bandai', 'This is probably the oldest game development company in the list. It was founded by another Japanese entrepreneur, Masaya Nakamura, in 1955. The company�s name is not so recognizable as the ones above, but when you think about Dragonball Z or Naruto, you should know that all of this was created by Namco Bandai.')
GO

INSERT INTO tblLANGUAGE(LanguageName, LanguageDescription)
VALUES
    ('English','spoken in USA, England, Australlia, New Zealand, and many more'),
    ('French','Spoken in France, Belgium, and many more'),
    ('Chinese','Spoken in China'),
    ('Japanese', 'Spoken in Japan'),
    ('German','Spoken in Germany')
GO

INSERT INTO tblPERSPECTIVE(PerpName, PerpDescription)
VALUES
    ('First Person','First person perspective allow you to view the game world through the main characters field of vision. This can vary from a viewpoint inside a cockpit of a plane, inside a vehicle of a racing game or the main type which is looking through a player�s viewpoint in a first person shooter. Call of Duty for example, allows you to view through the main character�s field of vision and allows you to see and experience what your character is going through, meaning that you are fully immersed into the game.'),
    ('Third Person','Third-person is a perspective in which the player can visibly see the body of the controlled gamer. The camera angle for third person games are mainly placed from an aerial view behind the character. Furthermore, third person perspective allows you to view more of the terrain and allows you to see enemies at all times, even when under cover. Third person games either place the player on the left hand side of the screen and may be fixed behind the character; as a result, not being able to see the characters face. Whereas most third person games place the character in the centre of the screen where you are able to pan the camera around them'),
    ('Aerial','Aerial is a birds eye viewpoint which is an elevated view of the character from above. This camera angle is used in video games that shows the characters and the area around them from above. it is most often used in 2D role playing video games and simulation games'),
    ('2D Scrolling','2D perspective view is a game which is built on a simple platform which uses a 2D view from the side which shows the character moving through the game world. an example of a game which uses a 2D viewpoint is ''Sonic the Hedgehog'' or ''Mario''. Games like these mostly consists of a player moving from the left hand side of the screen and defeating obstacles on the right hand side of the screen whilst moving towards the right. '),
    ('3 dimensional','Popular among puzzle and building games. Allows users to change position and view of whatever they are building.')
GO

INSERT INTO tblPLATFORM (PlatformName, PlatformDescription) 
VALUES 
    ('Xbox', 'The Microsoft Xbox gaming console platform'),
    ('Playstation', 'The Sony gaming console platform'),
    ('Stadia', 'The Google Stadia cloud gaming platform'),
    ('PC', 'The Microsoft Windows systen Personal Computer platform'),
    ('Mac', 'The Apple iOS System Personal Computer platform'),
    ('Switch', 'The Nintendo Switch Handheld gaming console platform')
GO

INSERT INTO tblPUBLISHER (PublisherName, PublisherDescription)
VALUES 
    ('Tencent Games', 'An investment and technology company based in China'),
    ('Sony Interactive', 'A US company based in San Mateo. It is a subsidiary of Sony Corporation'),
    ('Apple', 'A US technology company based in Cupertino')
GO
-- Publisher information from: https://geoshen.com/posts/15-largest-video-game-publishers-by-revenue

INSERT INTO tblGENDER (GenderName)
VALUES 
    ('Female'),
    ('Male')
GO

DECLARE @FemaleID INT = (SELECT GenderID FROM tblGENDER WHERE GenderName = 'Female')
DECLARE @MaleID INT = (SELECT GenderID FROM tblGENDER WHERE GenderName = 'Male')
INSERT INTO tblGAMER(GamerFname, GamerLname, GenderID, GamerDOB, GamerUsername)
VALUES 
    ('Augustus', 'Roadknight', @MaleID, '04/15/1996', 'aroadknight0'),
    ('Vonny', 'Whenman', @FemaleID, '01/23/1979', 'vwhenman1'),
    ('Jobie', 'Heinicke', @FemaleID, '03/06/1993', 'jheinicke2'),
    ('Pablo', 'Llorens', @MaleID, '02/20/1972', 'pllorens3'),
    ('Catriona', 'Custance', @FemaleID, '01/23/1994', 'ccustance4'),
    ('Elka', 'Graal', @FemaleID, '01/14/1996', 'egraal5'),
    ('Townie', 'Shacklady', @MaleID, '10/30/1978', 'tshacklady6'),
    ('Cad', 'Lanfare', @MaleID, '10/23/2008', 'clanfare7'),
    ('Clarisse', 'Chezier', @FemaleID, '11/08/2003', 'cchezier8'),
    ('Dorita', 'Dinley', @FemaleID, '10/25/1983', 'ddinley9'),
    ('Ellary', 'Sporle', @MaleID, '10/09/1973', 'esporlea'),
    ('Allina', 'McCaw', @FemaleID, '01/12/2001', 'amccawb'),
    ('Aleta', 'Van den Dael', @FemaleID, '03/21/1994', 'avandendaelc'),
    ('Ransell', 'Hoggetts', @MaleID, '01/18/1994', 'rhoggettsd'),
    ('Sheilakathryn', 'Duferie', @FemaleID, '01/10/1973', 'sduferiee'),
    ('Garwin', 'Fishbourn', @MaleID, '04/08/2000', 'gfishbournf'),
    ('Deeanne', 'Matthisson', @FemaleID, '03/19/1981', 'dmatthissong'),
    ('Regine', 'Mackriell', @FemaleID, '01/14/1997', 'rmackriellh'),
    ('Jeffrey', 'Stocking', @MaleID, '08/03/1995', 'jstockingi'),
    ('Gui', 'Cassells', @FemaleID, '10/29/2006', 'gcassellsj'),
    ('Cathlene', 'Rentenbeck', @FemaleID, '06/21/2007', 'crentenbeckk'),
    ('Tarrance', 'Mushet', @MaleID, '12/19/1988', 'tmushetl'),
    ('Flory', 'Warlow', @MaleID, '04/24/1979', 'fwarlowm'),
    ('Anselma', 'Wolseley', @FemaleID, '06/19/1979', 'awolseleyn'),
    ('Erich', 'Willmont', @MaleID, '02/04/2001', 'ewillmonto'),
    ('Urbanus', 'Preddle', @MaleID, '10/22/1993', 'upreddlep'),
    ('Adamo', 'Danilchev', @MaleID, '01/20/2015', 'adanilchevq'),
    ('Samara', 'Dumphy', @FemaleID, '06/01/1974', 'sdumphyr'),
    ('Durward', 'Croucher', @MaleID, '07/11/1999', 'dcrouchers'),
    ('Anatol', 'Hernik', @MaleID, '09/04/1998', 'ahernikt'),
    ('Gib', 'Blethyn', @MaleID, '10/08/2010', 'gblethynu'),
    ('Gertrud', 'Thying', @FemaleID, '05/09/1996', 'gthyingv'),
    ('Candide', 'Dmitrovic', @FemaleID, '09/13/1989', 'cdmitrovicw'),
    ('Vivyanne', 'Lanphere', @FemaleID, '11/03/2008', 'vlanpherex'),
    ('Kimbell', 'Matysiak', @MaleID, '02/13/2003', 'kmatysiaky'),
    ('Grayce', 'Roblou', @FemaleID, '02/15/2009', 'groblouz'),
    ('Godart', 'Shayes', @MaleID, '06/04/2003', 'gshayes10'),
    ('Malinda', 'Aberkirder', @FemaleID, '11/23/1978', 'maberkirder11'),
    ('Yolanthe', 'Youles', @FemaleID, '08/26/1997', 'yyoules12'),
    ('Mercy', 'Sircomb', @FemaleID, '02/08/1989', 'msircomb13'),
    ('Thorny', 'Skirvane', @MaleID, '05/18/2004', 'tskirvane14'),
    ('Elton', 'Ewols', @MaleID, '01/22/1973', 'eewols15'),
    ('Bertrand', 'Deerness', @MaleID, '12/11/1976', 'bdeerness16'),
    ('Karlyn', 'Benezet', @FemaleID, '12/22/1997', 'kbenezet17'),
    ('Roderich', 'Wager', @MaleID, '08/25/2012', 'rwager18'),
    ('Rosie', 'Colliver', @FemaleID, '10/01/2004', 'rcolliver19'),
    ('Marrissa', 'Eardley', @FemaleID, '06/23/2003', 'meardley1a'),
    ('Latrena', 'Jiles', @FemaleID, '05/01/2000', 'ljiles1b'),
    ('Helenelizabeth', 'Rozet', @FemaleID, '02/01/2015', 'hrozet1c'),
    ('Lamont', 'Bratcher', @MaleID, '01/22/1981', 'lbratcher1d'),
    ('Sashenka', 'Pridgeon', @FemaleID, '12/05/1978', 'spridgeon1e'),
    ('Eloise', 'Martusewicz', @FemaleID, '01/27/1987', 'emartusewicz1f'),
    ('Melly', 'Schustl', @FemaleID, '07/19/2009', 'mschustl1g'),
    ('Kylynn', 'Snoddy', @FemaleID, '07/11/2011', 'ksnoddy1h'),
    ('Jaquelyn', 'Merill', @FemaleID, '07/29/1983', 'jmerill1i'),
    ('Frazer', 'Alyoshin', @MaleID, '11/21/1973', 'falyoshin1j'),
    ('Jeramey', 'Locock', @MaleID, '06/15/2001', 'jlocock1k'),
    ('Johan', 'Tunnadine', @MaleID, '02/28/2009', 'jtunnadine1l'),
    ('Thain', 'Hebborn', @MaleID, '04/17/2007', 'thebborn1m'),
    ('Diana', 'Naper', @FemaleID, '09/11/2003', 'dnaper1n'),
    ('Flore', 'Syphas', @FemaleID, '06/09/1971', 'fsyphas1o'),
    ('Darius', 'Thurlby', @MaleID, '04/01/2003', 'dthurlby1p'),
    ('Oren', 'McLaren', @MaleID, '05/01/1973', 'omclaren1q'),
    ('Padriac', 'Brunner', @MaleID, '04/07/1994', 'pbrunner1r'),
    ('Anita', 'Feldmark', @FemaleID, '02/29/1984', 'afeldmark1s'),
    ('Floyd', 'Mardell', @MaleID, '04/03/1976', 'fmardell1t'),
    ('Robb', 'Wanne', @MaleID, '05/15/1972', 'rwanne1u'),
    ('Ermin', 'Wolfe', @MaleID, '09/08/2006', 'ewolfe1v'),
    ('Esta', 'Willisch', @FemaleID, '11/13/1986', 'ewillisch1w'),
    ('Lainey', 'Wigin', @FemaleID, '12/28/1991', 'lwigin1x'),
    ('Bartolomeo', 'Bernardinelli', @MaleID, '07/17/1988', 'bbernardinelli1y'),
    ('Curtice', 'Pakenham', @MaleID, '10/28/1979', 'cpakenham1z'),
    ('Kennan', 'Shoreson', @MaleID, '01/23/1996', 'kshoreson20'),
    ('Cecilio', 'Anglin', @MaleID, '02/20/1995', 'canglin21'),
    ('Jean', 'Tibalt', @MaleID, '11/12/1980', 'jtibalt22'),
    ('Rufe', 'Milazzo', @MaleID, '07/17/1980', 'rmilazzo23'),
    ('Ronda', 'Mouncher', @FemaleID, '12/09/2008', 'rmouncher24'),
    ('Cori', 'Shrieves', @MaleID, '11/23/1999', 'cshrieves25'),
    ('Angil', 'Van Arsdall', @FemaleID, '07/03/1977', 'avanarsdall26'),
    ('Horace', 'Dinkin', @MaleID, '08/24/1997', 'hdinkin27'),
    ('Bastien', 'Baszniak', @MaleID, '07/10/1970', 'bbaszniak28'),
    ('Burgess', 'Lingard', @MaleID, '08/18/1994', 'blingard29'),
    ('Tymon', 'Witt', @MaleID, '08/09/2014', 'twitt2a'),
    ('Porter', 'Elles', @MaleID, '09/28/2005', 'pelles2b'),
    ('Alvis', 'Kemson', @MaleID, '05/12/1982', 'akemson2c'),
    ('Mathilda', 'Parsisson', @FemaleID, '07/05/1999', 'mparsisson2d'),
    ('Linet', 'Rugg', @FemaleID, '01/01/1992', 'lrugg2e'),
    ('Fonsie', 'Grabb', @MaleID, '08/07/1973', 'fgrabb2f'),
    ('Reginauld', 'Golda', @MaleID, '03/18/2014', 'rgolda2g'),
    ('Christophorus', 'Peckitt', @MaleID, '11/17/1982', 'cpeckitt2h'),
    ('Sibilla', 'Foxten', @FemaleID, '08/19/1999', 'sfoxten2i'),
    ('Romona', 'Cabble', @FemaleID, '06/10/1998', 'rcabble2j'),
    ('Clerissa', 'Doyley', @FemaleID, '07/23/1986', 'cdoyley2k'),
    ('Saxe', 'Luisetti', @MaleID, '09/11/2011', 'sluisetti2l'),
    ('Ray', 'Stirrup', @FemaleID, '10/28/2013', 'rstirrup2m'),
    ('Bambi', 'McIlveen', @FemaleID, '10/06/2006', 'bmcilveen2n'),
    ('Cecil', 'Gerrans', @FemaleID, '01/24/2006', 'cgerrans2o'),
    ('Hillier', 'Pedri', @MaleID, '12/26/1979', 'hpedri2p'),
    ('Stavros', 'Dalliwater', @MaleID, '11/02/2003', 'sdalliwater2q'),
    ('Caryn', 'Sackey', @FemaleID, '09/26/1991', 'csackey2r')
GO 

-- [ Create non-look up tables ] -- 
CREATE TABLE tblGAME (
    GameID INT IDENTITY(1,1) primary key,
    GameName varchar(100),
    GenreTypeID INT FOREIGN KEY REFERENCES tblGENRE_TYPE(GenreTypeID) NOT NULL,
    GameReleaseDate DATE,
    -- GameRating numeric(5,2), (Computed)
    -- LanguageSupport INT, (Computed)
    -- PriceRange VARCHAR(50) (Computed)
    GameDescription varchar(600),
    PerpID INT FOREIGN KEY REFERENCES tblPERSPECTIVE(PerpID) NOT NULL,
    ParentRateID INT FOREIGN KEY REFERENCES tblPARENT_RATE(ParentRateID) NOT NULL
)
GO

CREATE TABLE tblDEVELOPER_GAME(
    DeveloperGameID INT IDENTITY(1,1) primary key,
    DeveloperID INT FOREIGN KEY REFERENCES tblDEVELOPER(DeveloperID) NOT NULL,
    GameID INT FOREIGN KEY REFERENCES tblGAME(GameID) NOT NULL
)
GO

CREATE TABLE tblGAME_LANGUAGE
    (GameLanguageID INT IDENTITY(1,1) primary key,
    LanguageID INT FOREIGN KEY REFERENCES tblLANGUAGE(LanguageID) NOT NULL,
    GameID INT FOREIGN KEY REFERENCES tblGAME(GameID) NOT NULL)
GO

CREATE TABLE tblORDER(
    OrderID INT PRIMARY KEY IDENTITY NOT NULL,
    GamerID INT FOREIGN KEY REFERENCES tblGAMER(GamerID) NOT NULL,
    OrderDate DATE NOT NULL,
    OrderTotal MONEY NOT NULL
)
GO

CREATE TABLE tblORDER_GAME(
    OrderGameID INT PRIMARY KEY IDENTITY NOT NULL,
    OrderID INT FOREIGN KEY REFERENCES tblORDER(OrderID) NOT NULL,
    GameID INT FOREIGN KEY REFERENCES tblGAME(GameID) NOT NULL,
    PlatformID INT FOREIGN KEY REFERENCES tblPLATFORM(PlatformID) NOT NULL,
    GamePrice MONEY NOT NULL,
    OrderGameQty INT NOT NULL,
    OrderGameSubprice MONEY
)
GO

CREATE TABLE tblREVIEW(
    ReviewID INT PRIMARY KEY IDENTITY NOT NULL,
    OrderGameID INT FOREIGN KEY REFERENCES tblORDER_GAME(OrderGameID) NOT NULL,
    ReviewRating FLOAT NOT NULL,
    ReviewContent VARCHAR(255),
    ReviewDate DATE NOT NULL
)
GO

CREATE TABLE tblGAMER_INTEREST(
    GamerInterestID INT PRIMARY KEY IDENTITY NOT NULL,
    GamerID INT FOREIGN KEY REFERENCES tblGAMER(GamerID) NOT NULL,
    KeywordID INT FOREIGN KEY REFERENCES tblKEYWORD(KeywordID) NOT NULL
)
GO

CREATE TABLE tblGAME_REGION_SALES(
	GameRegionSalesID INT IDENTITY(1,1) PRIMARY KEY,
	GameID INT FOREIGN KEY REFERENCES tblGAME (GameID) NOT NULL,
	RegionID INT FOREIGN KEY REFERENCES tblREGION (RegionID) NOT NULL,
	GameSalesNum INT NOT NULL
);
GO

CREATE TABLE tblGAME_KEYWORD(
	GameKeywordID INT IDENTITY(1,1) PRIMARY KEY,
	GameID INT FOREIGN KEY REFERENCES tblGAME (GameID) NOT NULL,
	KeywordID INT FOREIGN KEY REFERENCES tblKEYWORD (KeywordID) NOT NULL
);
GO

CREATE TABLE dbo.tblGamePlatform (
	GamePlatformID int PRIMARY KEY IDENTITY(1,1) Not Null,
	GameID int Not Null,
	PlatformID int Not Null,
    PlatformReleaseDate DATE NOT NULL,
    -- CurrentPrice MONEY (Computed)
	FOREIGN KEY (GameID) REFERENCES tblGame(GameID),
	FOREIGN KEY (PlatformID) REFERENCES tblPlatform(PlatformID)
)
GO 

CREATE TABLE dbo.tblGamePublisher (
	GamePublisherID	int PRIMARY KEY IDENTITY(1,1) Not Null,
	GameID int Not Null,
	PublisherID int Not Null,
	FOREIGN KEY (GameID) REFERENCES tblGame(GameID),
	FOREIGN KEY (PublisherID) REFERENCES tblPublisher(PublisherID)
)
GO 

CREATE TABLE dbo.tblPlatform_Price_History (
	PlatformHistoryID int PRIMARY KEY IDENTITY(1,1) Not Null,
	GamePlatformID int Not Null,
	HistoryPrice Money Not Null,
	HistoryStart Date Not Null,
    HistoryEnd Date Not Null,
	-- HistoryCurrent Bit Not Null, (Computed)
	FOREIGN KEY(GamePlatformID)	REFERENCES tblGamePlatform(GamePlatformID)
)
GO 

CREATE TABLE tblCART(
    CartID INT PRIMARY KEY IDENTITY NOT NULL,
    GameID INT FOREIGN KEY REFERENCES tblGAME(GameID) NOT NULL,
    PlatformID INT FOREIGN KEY REFERENCES tblPLATFORM(PlatformID) NOT NULL,
    GamerID INT FOREIGN KEY REFERENCES tblGAMER(GamerID) NOT NULL,
    CartQty INT NOT NULL,
    GamePrice MONEY NOT NULL,
    CartSubprice MONEY NOT NULL
)
GO
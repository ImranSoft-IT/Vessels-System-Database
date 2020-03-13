USE master;
GO
IF DB_ID ('VesselsDB') IS NOT NULL
DROP DATABASE VesselsDB;
GO
CREATE DATABASE VesselsDB 
ON (
		NAME = VesselsDB_data,
		FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\VesselsDB_data.mdf',
		SIZE = 10MB,
		MAXSIZE = 100MB,
		FILEGROWTH = 5%
) 
LOG ON(
		NAME = VesselsDB_log,
		FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\VesselsDB_log.ldf',
		SIZE = 5MB,
		MAXSIZE = 50MB,
		FILEGROWTH = 2MB
);
GO
USE VesselsDB;


CREATE TABLE Vessels (VesselID INT IDENTITY NOT NULL PRIMARY KEY, VesselName VARCHAR(50));
CREATE TABLE Ports (PortID INT IDENTITY NOT NULL PRIMARY KEY, PortName VARCHAR(40));
CREATE TABLE Flags (FlagID INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED, FlagName VARCHAR(30));
CREATE TABLE Agents (AgentID INT IDENTITY NOT NULL PRIMARY KEY, AgentName VARCHAR(50));
CREATE TABLE Piers (PierID INT IDENTITY NOT NULL PRIMARY KEY, PierName VARCHAR(30));



INSERT INTO Vessels VALUES  ('Alaskan Explorer'), ('Aquadisiac'), ('Aristaios'), ('Big Fish'), ('Cable Innovator'),
							('Cape Intrepid'), ('Cape Island'), ('Discover Bay'), ('Dragon'), ('Dunedin Star'), ('Ever Salute'),
							('Federal Island'), ('Explorer Oceania'), ('Federal Island'), ('Hyundai Courage'),
							('Hyundai Grace'), ('Jin Xia Feng'), ('Matson Producer'), ('Matson Tacoma'),
							('Mount Seymour'), ('Nancy Peterkin'), ('Navios citrine'), ('New Direction'),
							('Nord Crux'), ('Ocean Ambitious'), ('Ocean Phoenix');


INSERT INTO Flags VALUES ('USA'), ('LBR'), ('MHL'), ('GBR'), ('SGP'), ('BHS'), 
						 ('PAN'), ('HKG'), ('KOR'), ('MLT'), ('DIS');

INSERT INTO Ports VALUES ('Port Angeles'), ('Seattle'), ('March Point'), ('Tacoma'), ('Anacortes'), ('Bellingham'),
						 ('Manchester'), ('Vendovi Island'), ('Ferndate'), ('Cherry Point'), ('Panama'), ('Singapore'),
						 ('TBA'), ('Awt Orders'), ('Vancouver BC'), ('Temco'), ('Tokyo'), ('Taiwan'), ('Busan'), 
						 ('Anchorage'), ('Penang'), ('Manila'), ('Fishing Grounds');

INSERT INTO Agents VALUES ('ATC'), ('Tronsmarine'), ('General'), ('Pacific Coast Maritime'), ('Wilhelmsen Ship'),
						  ('Bluewater'), ('ACGI'), ('Hyundai'), ('Matson'), ('Kirby'), ('Interport PNW'), 
						  ('Inchcape'), ('Inchcape'), ('Premier');


INSERT INTO Piers VALUES ('Anchor'), ('Anchor-EBE'), ('Tesoro'), ('Lake Union'), ('1-North'), ('Sperry'),
						 ('Port Dock 2'), ('Cold Storage'), ('PCT-A&B'), ('86'), ('WA United'), ('Temco'), ('APM'),
						 ('Sehnitzen'), ('5-North'), ('90-7');


CREATE TABLE VesselsPorts 
(
	VesselID INT REFERENCES Vessels(VesselID),
	FlagID INT REFERENCES Flags (FlagID),
	PortID INT REFERENCES Ports (PortID),
	PierID INT REFERENCES Piers (PierID),
	AgentID INT REFERENCES Agents (AgentID),
	ExpectedDepartureDate DATETIME2 NULL,
	DestinationPortID INT REFERENCES Ports (PortID)
);



INSERT INTO VesselsPorts VALUES (1,1,1,1,1,'2018-10-24 02:00:00',10), (2,2,2,2,2,'2018-10-24 01:30:00',11), 
						(3,3,3,3,3,NULL, 12), (4,3,2,4,4,NULL,13), (5,4,1,5,5,NULL,13), (6,1,4,6,3,NULL, 14), 
						(7,1,4,6,3,NULL, 14), (8,5,5,7,3,NULL, 15), (9,6,4,1,6,NULL, 16), (10,6,6,8,2,NULL, 13), 
						(11,7,4,9,7, '2018-10-25 04:00:00',17), (12,8,2,10,6,null,18), (13,7,7,1,6,null,2),
						(14,9,4,11,8,'2018-10-24 13:00:00',19), (15,7,7,1,8,'2018-10-24 13:00:00', 15), 
						(16,7,4,11,8,'2018-10-25 17:00:00',15), (17,8,4,12,6,'2018-10-24 01:00:00',13),
						(18,1,4,13,9,null, 14), (19,1,4,13,9,'2018-10-24 22:00:00', 20), (20,8,4,14,5,null,21), 
						(21,1,2,15,10,null, 13), (22,7,4,1,6,'2018-10-24 01:00:00', 16), (23,7,1,1,11,'2018-10-24 23:00:00',22), 
						(24,5,4,1,7, null, 15), (25,8,2,2,12,'2018-10-26 12:00:00',13), (26,1,2,16,13,null, 23);


GO
--01. Create CLUSTERED INDEX------------------------------------
CREATE CLUSTERED INDEX IX_Clu_Flags ON Flags (FlagName);

GO
--02. Create Nonclustered INDEX---------------------------------
CREATE NONCLUSTERED INDEX IX_Vessels ON Vessels (VesselName);

GO
--03. Create view Vessel all information---------------------------------------------
Create view vw_VesselInformation as
Select  Vessels.VesselID, VesselName, FlagName, PortName, PierName, AgentName, 
		convert(varchar,ExpectedDepartureDate,0) AS ExpectedDepartureDate, 
		PortName AS DestinationPortID 
From Vessels JOIN VesselsPorts vp ON Vessels.VesselID = vp.VesselID
			 JOIN Flags ON Flags.FlagID = vp.FlagID
			 JOIN Ports ON Ports.PortID = vp.PortID
			 JOIN Piers ON Piers.PierID = vp.PierID
			 JOIN Agents ON Agents.AgentID = Vp.AgentID;
GO


--04. Create a complete copy of the 'vw_VesselInformation' Table;
Select * 
INTO Old_vesselInformation 
FROM vw_VesselInformation;


--05. Create a complete copy of the 'Old_vesselInformation' Table.
Select * 
INTO New_vesselInformation
FROM Old_vesselInformation;



GO
--06. Update table----------------------------------------------
Update Agents set AgentName = 'Premier' where AgentID = 13;



--07. Delete table row-------------------------------------------
Delete From New_vesselInformation where AgentName = 'New Direction';

GO
--13. Create view show all the information in a meaning full VesselDetails with encryption, schemabinding.
Create VIEW Vw_VesselDetails With Encryption, Schemabinding AS
Select  V.VesselID, VesselName, FlagName, PortName, PierName, AgentName, 
		convert(varchar,ExpectedDepartureDate,0) AS ExpectedDepartureDate, PortName AS DestinationPortID
FROM   dbo.Vessels V JOIN dbo.VesselsPorts VP ON V.VesselID = VP.VesselID
				 JOIN dbo.Flags F ON F.FlagID = vp.FlagID
				 JOIN dbo.Ports P ON p.PortID = vp.PortID
				 JOIN dbo.Piers Pi oN pi.PierID = vp.PierID
				 JOIN dbo.Agents A ON A.AgentID = vp.AgentID
Where FlagName = 'USA' 
with Check option;
GO


--14. Table variables -------------------------------
DECLARE @NewFlag TABLE 
(
	FlagID INT PRIMARY KEY,
	FlagName VARCHAR (50)
);
INSERT INTO @NewFlag VALUES 
(12, 'DEU'),
(13, 'GRC')
;
INSERT INTO Flags (FlagName) SELECT FlagName FROM @NewFlag;
GO



--17. Create insert Store Procedure and include input parameter
Create Proc SP_VesselDetails (
	@VesselName varchar(40)
) AS
insert into vessels ( VesselName) 
Values ( @VesselName);


GO
--18. Create Updateable Store Procedure ---------------------------------
Create Proc sp_UpdateVessel (
	@VesselID INT,
	@VesselName varchar(40)
) AS
Update Vessels SET VesselName = @VesselName
Where  VesselID = @VesselID;
GO


--19. Create Delete Store Procedure ---------------------------------
Create Proc sp_DeleteVesselInformation (@VesselID int)
AS
Delete From New_vesselInformation Where VesselID = @VesselID;
GO



--20. Create  a table valued function that takes the Vessel ID as paraneter and returns the Vessels details.
create function Fn_GetVessel (@vesselID int)
returns table
as
return select * from Vessels where VesselID = @vesselID;


GO
--21. Create  a Sclaer valued function that takes the Vessel ID as paraneter and returns the Vessels details.
Create Function fn_VesselDeatils()
Returns int 
AS 
Begin
	Return (Select Count(*) From New_vesselInformation);
END;


GO

--22. Create After Delete Trigger-------------------------- 
CREATE TRIGGER Tr_vesselInformation
ON New_vesselInformation
AFTER DELETE 
AS 
INSERT INTO Old_vesselInformation (VesselID, VesselName, FlagName, PortName, PierName, AgentName, ExpectedDepartureDate, DestinationPortID)
SELECT	VesselID, VesselName, FlagName, PortName, PierName, AgentName, ExpectedDepartureDate, DestinationPortID FROM deleted;

GO


--23. Create instead of insert Trigger Custome Error-------------------------- 
Create Trigger Trg_VarifyVesselName ON Old_vesselInformation
Instead of insert
AS 
IF exists
(	 Select * from Old_vesselInformation 
	where VesselName = (Select VesselName From inserted) 
	and FlagName = (Select FlagName From inserted)
)
Throw 50045, 'Vesserl is already exists!', 1;
Else 
insert into Old_vesselInformation 
select VesselID, VesselName, FlagName, PortName, PierName, 
		AgentName, ExpectedDepartureDate, DestinationPortID
From inserted;

Go
--insert Row
insert into New_vesselInformation values (27, 'New DirectionL', 'USA', 'Angeles', 
				'Anchor-BM', 'Interport', '2018-10-27 11:00:00','Pot Angeles')
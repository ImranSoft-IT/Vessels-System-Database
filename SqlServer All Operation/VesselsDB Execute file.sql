Use master;
GO
USE VesselsDB;

Go


select * from Vessels;
select * from Flags;
select * from Ports;
select * from Agents;
select * from Piers;
select *  from VesselsPorts;


--01. CLUSTERED INDEX------------------------------------
EXEC sp_helpindex 'Flags';

--02. Nonclustered INDEX---------------------------------
EXEC sp_helpindex 'Vessels';

--03. View Vessel all information------------------------
SELECT * FROM vw_VesselInformation;

--04. Create a complete copy of the 'vw_VesselInformation' Table.
Select * from Old_vesselInformation;

--05. Create a complete copy of the 'Old_vesselInformation' Table.
Select * FROM New_vesselInformation;

--06. Update table----------------------------------------------
select * From Agents where AgentID = 13;

--07. Delete table row-------------------------------------------
Select * from New_vesselInformation;

GO
--15. Declare SCALAR variable------------------------------
DECLARE @i INT = 0, @Number INT = 10;
WHILE (@i < 5)
BEGIN
	PRINT @Number;
	SET @Number = @Number * 10;
	SET @i = @i + 1; 
END
GO
DECLARE @i INT = 5, @Number INT = 100000;
WHILE (@i > 0)
BEGIN
	PRINT @Number;
	SET @Number = @Number / 10;
	SET @i = @i - 1; 
END
GO
CREATE PROC sp_PrintSeriesBase10 
@i INT, @Number INT
AS
WHILE (@i < 5)
BEGIN
	PRINT @Number;
	SET @Number = @Number * 10;
	SET @i = @i + 1; 
END


GO
--08. INNER JOIN show all information-----------------------------
Select  VesselName, FlagName, PortName, PierName, AgentName, 
		convert(varchar,ExpectedDepartureDate,0) AS ExpectedDepartureDate, 
		PortName AS DestinationPortID 
From Vessels JOIN VesselsPorts vp ON Vessels.VesselID = vp.VesselID
			 JOIN Flags ON Flags.FlagID = vp.FlagID
			 JOIN Ports ON Ports.PortID = vp.PortID
			 JOIN Piers ON Piers.PierID = vp.PierID
			 JOIN Agents ON Agents.AgentID = Vp.AgentID
WHERE FlagName = 'USA';


--09. Self-Join by View---------------------------------------
SELECT DISTINCT vw_VLIm1.AgentName, 
				vw_VLIm1.FlagName, 
				vw_VLIm2.PortName
FROM    vw_VesselInformation as vw_VLIm1 
   JOIN vw_VesselInformation as vw_VLIm2 
ON vw_VLIm1.AgentName = vw_VLIm2.AgentName
 AND vw_VLIm1.FlagName = vw_VLIm2.FlagName
 AND vw_VLIm1.PortName = vw_VLIm2.PortName
ORDER BY vw_VLIm1.AgentName DESC;

--10. A Union that combines 'VesselInformation' from two different tables.
	Select 'New Information' AS Source, VesselName, FlagName, PortName, AgentName 
	FROM New_vesselInformation Where PortName = 'Tacoma'
UNION
	Select 'Old Information' AS Source, VesselName, FlagName, PortName, AgentName
	FROM Old_vesselInformation where FlagName = 'PAN'
ORDER by VesselName DESC;


--11. Aggregate functions and include Group by, Having clause---------
Select  VesselName, FlagName, COUNT(Ports.PortID) AS Portid, PierName, AgentName, 
		convert(varchar,ExpectedDepartureDate,3) AS ExpectedDepartureDate, 
		PortName AS DestinationPortID 
From Vessels JOIN VesselsPorts vp ON Vessels.VesselID = vp.VesselID
			 JOIN Flags ON Flags.FlagID = vp.FlagID
			 JOIN Ports ON Ports.PortID = vp.PortID
			 JOIN Piers ON Piers.PierID = vp.PierID
			 JOIN Agents ON Agents.AgentID = Vp.AgentID
Group by VesselName, FlagName, PierName, AgentName, ExpectedDepartureDate, PortName
Having FlagName in (Select FlagName from Flags Where FlagName = 'PAN');


--12. Create Common Table Expressions ----------------------------
WITH CTE1 AS
(
	Select VesselName, FlagName, PortName, PierName 
	FROM Vessels Vl JOIN VesselsPorts VlP ON Vl.VesselID = Vlp.VesselID
					JOIN Flags Fg ON Fg.FlagID = Vlp.FlagID
					JOIN Ports Pt ON Pt.PortID = Vlp.PortID
					JOIN Piers ON Piers.PierID = Vlp.PierID
	Where FlagName = 'PAN'
),
CTE2 AS
(
	Select PierName, max(AgentName) as Agents, ExpectedDepartureDate, PortName as DestinationPortID
	FROM Piers JOIN VesselsPorts ON Piers.PierID = VesselsPorts.PierID
				JOIN Agents ON Agents.AgentID = VesselsPorts.AgentID
				JOIN Ports ON Ports.PortID = VesselsPorts.PortID
	Group by PierName, ExpectedDepartureDate, DestinationPortID, PortName
)
SELECT CTE1.VesselName, CTE1.FlagName, CTE1.PortName, CTE2.PierName, CTE2.Agents, 
		CTE2.ExpectedDepartureDate, DestinationPortID
FROM  CTE1 JOIN CTE2 ON CTE1.PierName = CTE2.PierName
Order BY CTE1.PortName;


--13. Create view show all the information in a meaning full VesselDetails with encryption, schemabinding.
Select * From Vw_VesselDetails;

--14. Table variables -------------------------------
SELECT * FROM Flags;

--16. Try Catch Statement----------------------
Begin try 
	insert into New_vesselInformation (VesselID, VesselName, FlagName, PortName, PierName, AgentName, ExpectedDepartureDate, DestinationPortID)
	values (20, 'DUBLIN SEA (T)', 'LRB', 'MARCH POINT', 'Shell', 'NORTON LILLY', '2018-05-29 4:30:00', '5');
	Print 'Success: Record was inserted.';
END Try
Begin Catch
	Print 'Failure: Record was not inserted.'
	Print 'Error ' + Convert(Varchar, error_Number(), 1) + ':' + Error_Message();
End Catch;

--17. Create insert Store Procedure and include input parameter
EXEC SP_VesselDetails 'DUBLIN SEA (T)'
select * from Vessels;
GO

--18. Create Updateable Store Procedure ---------------------------------
EXEC sp_UpdateVessel 27,'AMIS WISDOM III'
GO
Select * From Vessels order by VesselID asc;
GO

--19. Create Delete Store Procedure ---------------------------------
EXEC sp_DeleteVesselInformation 15
GO
Select * From New_vesselInformation;
GO

--20. Create  a table valued function that takes the Vessel ID as paraneter and returns the Vessels details.
Select * from dbo.Fn_GetVessel(3);
GO

--21. Create  a Sclaer valued function that takes the Vessel ID as paraneter and returns the Vessels details.
Print 'Total Vessels: ' + Convert(varchar, dbo.fn_VesselDeatils(),1);
GO

--22. Create After Delete Trigger-------------------------- 
delete from New_vesselInformation where VesselID = 27;

SELECT	* FROM New_vesselInformation Order by VesselID asc;
SELECT * FROM Old_vesselInformation order by vesselID asc;

GO

--23. Create instead of insert Trigger Custome Error-------------------------- 
Begin try
	insert into Old_vesselInformation values (23, 'New Direction', 'PAN', 'Port Angeles', 
				'Anchor', 'Interport PNW', '2018-10-24 11:00:00','Port Angeles');
End try
Begin catch
print 'Custome Error!'
End catch;
GO



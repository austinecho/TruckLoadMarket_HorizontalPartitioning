/*
DataTeam
databaseName Partitioning

DBA:
-Monitor Transaction Logs and Blocking throughout process

•	DROP FK w/if exist
•	DROP PK w/if exist (Result Heap on all table in set)
•	ADD Partition Column and Back Fill Data
•	ALTER NULL Column and ADD DF 
•	ADD Clustered
•	ADD PK
•	ADD UX
•	ADD FK
•	Update Stats
	(The final state will be verified in a different step)

Run in DB01VPRD Equivilant 
*/
USE databaseName
GO

--===================================================================================================
--[START]
--===================================================================================================
PRINT '********************';
PRINT '!!! Script START !!!';
PRINT '********************';

IF ( SELECT @@SERVERNAME ) = 'DB01VPRD' BEGIN PRINT 'Running in Environment DB01VPRD...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'QA4-DB01' BEGIN PRINT 'Running in Environment QA4-DB01...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01' BEGIN PRINT 'Running in Environment DATATEAM4-DB01\DB01...'; END;
ELSE BEGIN PRINT 'ERROR: Server name not found. Process stopped.'; RETURN; END;


--===================================================================================================
--[REMOVE FK]
--===================================================================================================
--PRINT '*****************';
--PRINT '*** Remove FK ***';
--PRINT '*****************';


----************************************************
--PRINT 'Working on table [dbo].[tblLoadStop] ...'; 

--IF EXISTS (   SELECT 1
--              FROM   sys.foreign_keys
--              WHERE  name = 'FK_tblLoadStop_tblLoadCustomer'
--                AND  parent_object_id = OBJECT_ID( N'dbo.tblLoadStop' ))
--BEGIN
--    ALTER TABLE dbo.tblLoadStop DROP CONSTRAINT FK_tblLoadStop_tblLoadCustomer;
--    PRINT '- FK [FK_tblLoadStop_tblLoadCustomer] Dropped';
--END;
--ELSE IF EXISTS (   SELECT 1
--                   FROM   sys.foreign_keys
--                   WHERE  name = 'FK_tblLoadStop_tblLoadCustomer_LoadCustomerID'
--                     AND  parent_object_id = OBJECT_ID( N'dbo.tblLoadStop' ))
--	BEGIN
--	    ALTER TABLE dbo.tblLoadStop DROP CONSTRAINT FK_tblLoadStop_tblLoadCustomer_LoadCustomerID;
--	    PRINT '- FK [FK_tblLoadStop_tblLoadCustomer_LoadCustomerID] Dropped';
--	END;
--ELSE
--BEGIN
--    PRINT '!! WARNING: Foreign Key not found !!';
--END;
--GO


--===================================================================================================
--[REMOVE ALL PKs]
--===================================================================================================
PRINT '***************************';
PRINT '*** Remove PK/Clustered ***';
PRINT '***************************';

--************************************************
PRINT 'Working on table [schemaName].[tableName] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'schemaName.tableName' )
				AND  name = N'PUT PK NAME HERE'
          )
BEGIN    
	ALTER TABLE schemaName.tableName DROP CONSTRAINT --PK_tblLoadCustomer;
    PRINT '- PK [PUT PK NAME HERE] Dropped';
END;


--===================================================================================================
--[ADD PARTITION COLUMNs]
--===================================================================================================
--PRINT '*****************************';
--PRINT '*** Add Partition Columns ***';
--PRINT '*****************************';

----************************************************
--PRINT 'Working on table [dbo].[tblLoadStop] ...';

--IF NOT EXISTS (	SELECT 1
--				FROM sys.columns
--				WHERE name = 'CreatedDate'
--				AND object_id = OBJECT_ID(N'dbo.tblLoadStop'))
--BEGIN
--	ALTER TABLE dbo.tblLoadStop
--	ADD CreatedDate DATETIME NULL
--	PRINT '- Column [CreatedDate] Created';
--END;
--GO


--===================================================================================================
--[BACK FILL DATA]
--===================================================================================================
--PRINT '**********************';
--PRINT '*** Back Fill Data ***';
--PRINT '**********************';

----************************************************
--PRINT 'Working on table [dbo].[tblLoadStop] ...';

--BEGIN TRY
--	IF OBJECT_ID('tempdb..#LoadStopCreatedDate') IS NOT	NULL DROP TABLE #LoadStopCreatedDate;
--	CREATE TABLE #LoadStopCreatedDate (LoadStopCreatedDateID INT IDENTITY(1,1) PRIMARY KEY, LoadStopID INT, CreatedDate DATETIME);

--	WITH FirstLoadStopDate AS
--	(
--		SELECT LoadCustomerID, MIN(StopDate) AS StopDate
--		FROM dbo.tblLoadStop
--		GROUP BY LoadCustomerID
--		HAVING MIN(StopDate) IS NOT NULL
--	)
--	INSERT INTO #LoadStopCreatedDate(LoadStopID, CreatedDate)
--	SELECT ls.LoadStopID, CASE WHEN ls.StopDate IS NULL THEN flsd.StopDate ELSE ls.StopDate END AS CreatedDate
--	FROM dbo.tblLoadStop ls
--	INNER JOIN FirstLoadStopDate flsd ON ls.LoadCustomerID = flsd.LoadCustomerID

--	CREATE NONCLUSTERED INDEX IX_#LoadStopCreatedDate_LoadStopID_Incl
--	ON #LoadStopCreatedDate (LoadStopID)
--	INCLUDE (CreatedDate)

--	DECLARE @BatchCt INT;
--	DECLARE @LoopCt INT;
--	DECLARE @LoopMax INT;

--	SET @BatchCt = 500000
--	SET @LoopCt = ((SELECT MIN(LoadStopCreatedDateID) FROM #LoadStopCreatedDate)-1)
--	SET @LoopMax = (SELECT MAX(LoadStopCreatedDateID) FROM #LoadStopCreatedDate)

--	WHILE @LoopCt < @LoopMax
--	BEGIN
--		BEGIN TRANSACTION

--		UPDATE ls
--		SET ls.CreatedDate = lscd.CreatedDate
--		FROM dbo.tblLoadStop ls
--		INNER JOIN #LoadStopCreatedDate lscd ON ls.LoadStopID = lscd.LoadStopID
--		WHERE lscd.LoadStopCreatedDateID BETWEEN @LoopCt + 1 AND @LoopCt + @BatchCt;

--		SET @LoopCt = @LoopCt + @BatchCt

--		COMMIT TRANSACTION
--	END
	
--	BEGIN TRANSACTION
--		UPDATE dbo.tblLoadStop
--		SET CreatedDate = '1753-01-01 00:00:00.000'
--		WHERE CreatedDate IS NULL

--		UPDATE dbo.tblLoadCustomer
--		SET CreateDate = '1753-01-01 00:00:00.000'
--		WHERE CreateDate IS NULL
--	COMMIT TRANSACTION
	
--	PRINT '- Back fill data Done';
--END TRY
--BEGIN CATCH
--	IF @@TRANCOUNT > 0
--	BEGIN
--		ROLLBACK TRANSACTION;
--	END;

--	THROW;
--END CATCH;


--===================================================================================================
--[ALTER NULL COLUMN AND ADD DF]
--===================================================================================================
PRINT '************************************';
PRINT '*** Alter NULL Column And Add DF ***';
PRINT '************************************';

--******************************************************
PRINT 'Working on table [dbo].[tblLoadCustomer] ...';

IF EXISTS (   SELECT 1
                  FROM   sys.default_constraints
                  WHERE  name = 'CONSTRAINT NAME'
                    AND  parent_object_id = OBJECT_ID( N'schemaName.tableName' ))
BEGIN
    ALTER TABLE schemaName.tableName DROP CONSTRAINT CONSTRAINTNAME
    PRINT '- DF [CONSTRAINT NAME] Dropped';
END;

IF EXISTS (   SELECT 1
              FROM   sys.columns
              WHERE  name = 'columnName'
                AND  object_id = OBJECT_ID( N'schemaName.tableName' )
                AND  is_nullable = 1 )
BEGIN
    ALTER TABLE schemaName.tableName ALTER COLUMN columnName DATETIME NOT NULL;
    PRINT '- Column [columnName] Changed to Not Null';
END;

IF NOT EXISTS (   SELECT 1
                  FROM   sys.default_constraints
                  WHERE  name = 'CONSTRAINT NAME'
                    AND  parent_object_id = OBJECT_ID( N'schemaName.tableName' ))
BEGIN
    ALTER TABLE schemaName.tableName ADD CONSTRAINT CONSTRAINTNAME DEFAULT GETDATE() FOR columnName;
    PRINT '- DF [CONSTRAINT NAME] Created';
END;
GO

--===================================================================================================
--[CREATE CLUSTERED INDEX]
--===================================================================================================
PRINT '******************************';
PRINT '*** Create Clustered Index ***';
PRINT '******************************';

--************************************************
PRINT 'Working on table [schemaName].[tableName] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_tableName_columnName' )
BEGIN
    DROP INDEX CIX_tableName_columnName ON schemaName.tableName;
	PRINT '- Index [CIX_tableName_columnName] Dropped';
END;

CREATE CLUSTERED INDEX CIX_tableName_columnName
ON schemaName.tableName ( columnName ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_databaseName_partitionColumnType_partitionRange(columnName);
PRINT '- Index [CIX_tableName_columnName] Created';


--===================================================================================================
--[CREATE PKs]
--===================================================================================================
PRINT '******************';
PRINT '*** Create PKs ***';
PRINT '******************';

--************************************************
PRINT 'Working on table [schemaName].[tableName] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_tableName_originalPrimaryKeyColumnName_columnName' )
BEGIN
    ALTER TABLE schemaName.tableName DROP CONSTRAINT PK_tableName_originalPrimaryKeyColumnName_columnName;
	PRINT '- PK [PK_tableName_originalPrimaryKeyColumnName_columnName] Dropped';
END;

ALTER TABLE schemaName.tableName
ADD CONSTRAINT PK_tableName_originalPrimaryKeyColumnName_columnName
    PRIMARY KEY NONCLUSTERED ( originalPrimaryKeyColumnName, columnName)
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_databaseName_partitionColumnType_partitionRange(columnName);
PRINT '- PK [PK_tableName_originalPrimaryKeyColumnName_columnName] Created';


--===================================================================================================
--[CREATE UX]
--===================================================================================================
--PRINT '***************************';
--PRINT '*** Create Unique Index ***';
--PRINT '***************************';

----************************************************
--PRINT 'Working on table [dbo].[tblLoadCustomer] ...';

--IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'UX_tblLoadCustomer_LoadCustomerID' )
--BEGIN
--    DROP INDEX UX_tblLoadCustomer_LoadCustomerID ON dbo.tblLoadCustomer;
--	PRINT '- Index [UX_tblLoadCustomer_LoadCustomerID] Dropped';
--END;

--CREATE UNIQUE NONCLUSTERED INDEX UX_tblLoadCustomer_LoadCustomerID
--ON dbo.tblLoadCustomer ( LoadCustomerID )
--WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON [PRIMARY];
--PRINT '- Index [UX_tblLoadCustomer_LoadCustomerID] Created';
--GO


--===================================================================================================
--[CREATE FK]
--===================================================================================================
--PRINT '*****************';
--PRINT '*** Create FK ***';
--PRINT '*****************';

----*****************************************************
--PRINT 'Working on table [dbo].[tblLoadStop] ...';

--ALTER TABLE dbo.tblLoadStop WITH NOCHECK
--ADD CONSTRAINT FK_tblLoadStop_tblLoadCustomer_LoadCustomerID
--    FOREIGN KEY ( LoadCustomerID )
--    REFERENCES dbo.tblLoadCustomer ( LoadCustomerID ) 
--	ON DELETE CASCADE
--	ON UPDATE CASCADE;
--PRINT '- FK [FK_tblLoadStop_tblLoadCustomer_LoadCustomerID] Created';

--ALTER TABLE dbo.tblLoadStop CHECK CONSTRAINT FK_tblLoadStop_tblLoadCustomer_LoadCustomerID;
--PRINT '- FK [FK_tblLoadStop_tblLoadCustomer_LoadCustomerID] Enabled';
--GO

--===================================================================================================
--[UPDATE STATS]
--===================================================================================================
PRINT '********************';
PRINT '*** Update Stats ***';
PRINT '********************';

--************************************************
PRINT 'Working on table [schemaName].[tableName] ...';

UPDATE STATISTICS schemaName.tableName;
PRINT '- Statistics Updated';


--===================================================================================================
--[DONE]
--===================================================================================================
PRINT '***********************';
PRINT '!!! Script COMPLETE !!!';
PRINT '***********************';
/*
DataTeam
TruckLoadMarket Partitioning

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
USE TruckLoadMarket
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
PRINT '*****************';
PRINT '*** Remove FK ***';
PRINT '*****************';


--************************************************
PRINT 'Working on table [LoadToEquip].[LoadToEquipment] ...'; 

IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_LoadToEquipment_MarketFile'
                AND  parent_object_id = OBJECT_ID( N'LoadToEquip.LoadToEquipment' ))
BEGIN
    ALTER TABLE LoadToEquip.LoadToEquipment DROP CONSTRAINT FK_LoadToEquipment_MarketFile;
    PRINT '- FK [FK_LoadToEquipment_MarketFile] Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_LoadToEquip_LoadToEquipment_Log_MarketFile_MarketFileID'
                     AND  parent_object_id = OBJECT_ID( N'LoadToEquip.LoadToEquipment' ))
	BEGIN
	    ALTER TABLE LoadToEquip.LoadToEquipment DROP CONSTRAINT FK_LoadToEquip_LoadToEquipment_Log_MarketFile_MarketFileID;
	    PRINT '- FK [FK_LoadToEquip_LoadToEquipment_Log_MarketFile_MarketFileID] Dropped';
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO

IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'fk_Market_DestMarketID'
                AND  parent_object_id = OBJECT_ID( N'LoadToEquip.LoadToEquipment' ))
BEGIN
    ALTER TABLE LoadToEquip.LoadToEquipment DROP CONSTRAINT fk_Market_DestMarketID;
    PRINT '- FK [fk_Market_DestMarketID] Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_LoadToEquip_LoadToEquipment_DestMarketID_Reference_Market_MarketID'
                     AND  parent_object_id = OBJECT_ID( N'LoadToEquip.LoadToEquipment' ))
	BEGIN
	    ALTER TABLE LoadToEquip.LoadToEquipment DROP CONSTRAINT FK_LoadToEquip_LoadToEquipment_DestMarketID_Reference_Market_MarketID;
	    PRINT '- FK [FK_LoadToEquip_LoadToEquipment_DestMarketID_Reference_Market_MarketID] Dropped';
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO

IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'fk_Market_OriginMarketID'
                AND  parent_object_id = OBJECT_ID( N'LoadToEquip.LoadToEquipment' ))
BEGIN
    ALTER TABLE LoadToEquip.LoadToEquipment DROP CONSTRAINT fk_Market_OriginMarketID;
    PRINT '- FK [fk_Market_OriginMarketID] Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_LoadToEquip_LoadToEquipment_OriginMarketID_Reference_Market_MarketID'
                     AND  parent_object_id = OBJECT_ID( N'LoadToEquip.LoadToEquipment' ))
	BEGIN
	    ALTER TABLE LoadToEquip.LoadToEquipment DROP CONSTRAINT FK_LoadToEquip_LoadToEquipment_OriginMarketID_Reference_Market_MarketID;
	    PRINT '- FK [FK_LoadToEquip_LoadToEquipment_OriginMarketID_Reference_Market_MarketID] Dropped';
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO


--===================================================================================================
--[REMOVE ALL PKs]
--===================================================================================================
PRINT '***************************';
PRINT '*** Remove PK/Clustered ***';
PRINT '***************************';

--************************************************
PRINT 'Working on table [LoadToEquip].[LoadToEquipment] ...';

IF @@SERVERNAME = 'DB01VPRD'
BEGIN

	IF EXISTS (   SELECT 1
				  FROM   sys.objects
				  WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
					AND  parent_object_id = OBJECT_ID( N'LoadToEquip.LoadToEquipment' )
					AND  name = N'PK__LoadToEq__0A6E807B7F60ED59'
			  )
	BEGIN    
		ALTER TABLE LoadToEquip.LoadToEquipment DROP CONSTRAINT PK__LoadToEq__0A6E807B7F60ED59;
		PRINT '- PK [PK__LoadToEq__0A6E807B7F60ED59] Dropped';
	END;
END

ELSE IF @@SERVERNAME LIKE 'QA%'
BEGIN

	IF EXISTS (   SELECT 1
				  FROM   sys.objects
				  WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
					AND  parent_object_id = OBJECT_ID( N'LoadToEquip.LoadToEquipment' )
					AND  name = N'PK__LoadToEq__0A6E807B7F60ED59'
			  )
	BEGIN    
		ALTER TABLE LoadToEquip.LoadToEquipment DROP CONSTRAINT PK__LoadToEq__0A6E807B7F60ED59;
		PRINT '- PK [PK__LoadToEq__0A6E807B7F60ED59] Dropped';
	END;
END

ELSE IF @@SERVERNAME = 'DATATEAM4-DB01\DB01'
BEGIN

	IF EXISTS (   SELECT 1
				  FROM   sys.objects
				  WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
					AND  parent_object_id = OBJECT_ID( N'LoadToEquip.LoadToEquipment' )
					AND  name = N'PK__LoadToEq__0A6E807B014935CB'
			  )
	BEGIN    
		ALTER TABLE LoadToEquip.LoadToEquipment DROP CONSTRAINT PK__LoadToEq__0A6E807B014935CB;
		PRINT '- PK [PK__LoadToEq__0A6E807B014935CB] Dropped';
	END;
END

--===================================================================================================
--[REMOVE NON CLUSTERED INDEX]
--===================================================================================================
PRINT '******************************';
PRINT '*** Remove Non Clustered Index ***';
PRINT '******************************';

--************************************************
PRINT 'Working on table [LoadToEquip].[LoadToEquipment] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'IX_LoadToEquipment_DestMarketID_OriginMarketID' )
BEGIN
    DROP INDEX IX_LoadToEquipment_DestMarketID_OriginMarketID ON LoadToEquip.LoadToEquipment;
	PRINT '- Index [IX_LoadToEquipment_DestMarketID_OriginMarketID] Dropped';
END;

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'IX_LoadToEquipment_EquipmentCategoryCode_DestMarketID_OriginMarketID' )
BEGIN
    DROP INDEX IX_LoadToEquipment_EquipmentCategoryCode_DestMarketID_OriginMarketID ON LoadToEquip.LoadToEquipment;
	PRINT '- Index [IX_LoadToEquipment_EquipmentCategoryCode_DestMarketID_OriginMarketID] Dropped';
END;

--===================================================================================================
--[CREATE CLUSTERED INDEX]
--===================================================================================================
PRINT '******************************';
PRINT '*** Create Clustered Index ***';
PRINT '******************************';

--************************************************
PRINT 'Working on table [LoadToEquip].[LoadToEquipment] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_LoadToEquip_LoadToEquipment_RecordedDate ' )
BEGIN
    DROP INDEX CIX_LoadToEquip_LoadToEquipment_RecordedDate  ON LoadToEquip.LoadToEquipment;
	PRINT '- Index [CIX_LoadToEquip_LoadToEquipment_RecordedDate] Dropped';
END;

CREATE CLUSTERED INDEX CIX_LoadToEquip_LoadToEquipment_RecordedDate 
ON LoadToEquip.LoadToEquipment ( RecordedDate ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_TruckLoadMarket_SMALLDATETIME_1Year(RecordedDate);
PRINT '- Index [CIX_LoadToEquip_LoadToEquipment_RecordedDate] Created';


--===================================================================================================
--[CREATE PKs]
--===================================================================================================
PRINT '******************';
PRINT '*** Create PKs ***';
PRINT '******************';

--************************************************
PRINT 'Working on table [LoadToEquip].[LoadToEquipment] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_LoadToEquip_LoadToEquipment_LoadToEquipmentID_RecordedDate ' )
BEGIN
    ALTER TABLE LoadToEquip.LoadToEquipment DROP CONSTRAINT PK_LoadToEquip_LoadToEquipment_LoadToEquipmentID_RecordedDate ;
	PRINT '- PK [PK_LoadToEquip_LoadToEquipment_LoadToEquipmentID_RecordedDate ] Dropped';
END;

ALTER TABLE LoadToEquip.LoadToEquipment
ADD CONSTRAINT PK_LoadToEquip_LoadToEquipment_LoadToEquipmentID_RecordedDate 
    PRIMARY KEY NONCLUSTERED ( LoadToEquipmentID, RecordedDate)
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_TruckLoadMarket_SMALLDATETIME_1Year(RecordedDate);
PRINT '- PK [PK_LoadToEquip_LoadToEquipment_LoadToEquipmentID_RecordedDate] Created';

--===================================================================================================
--[CREATE FK]
--===================================================================================================
PRINT '*****************';
PRINT '*** Create FK ***';
PRINT '*****************';

--*****************************************************
PRINT 'Working on table [LoadToEquip].[LoadToEquipment] ...';

ALTER TABLE LoadToEquip.LoadToEquipment WITH NOCHECK
ADD CONSTRAINT FK_LoadToEquip_LoadToEquipment_Log_MarketFile_MarketFileID
    FOREIGN KEY ( MarketFileID )
    REFERENCES [Log].[MarketFile] ( MarketFileID ) 
PRINT '- FK [FK_LoadToEquip_LoadToEquipment_Log_MarketFile_MarketFileID] Created';

ALTER TABLE LoadToEquip.LoadToEquipment CHECK CONSTRAINT FK_LoadToEquip_LoadToEquipment_Log_MarketFile_MarketFileID;
PRINT '- FK [FK_LoadToEquip_LoadToEquipment_Log_MarketFile_MarketFileID] Enabled';
GO

ALTER TABLE LoadToEquip.LoadToEquipment WITH NOCHECK
ADD CONSTRAINT FK_LoadToEquip_LoadToEquipment_DestMarketID_Reference_Market_MarketID
    FOREIGN KEY ( DestMarketID )
    REFERENCES Reference.Market ( MarketID ) 
PRINT '- FK [FK_LoadToEquip_LoadToEquipment_DestMarketID_Reference_Market_MarketID] Created';

ALTER TABLE LoadToEquip.LoadToEquipment CHECK CONSTRAINT FK_LoadToEquip_LoadToEquipment_DestMarketID_Reference_Market_MarketID;
PRINT '- FK [FK_LoadToEquip_LoadToEquipment_DestMarketID_Reference_Market_MarketID] Enabled';
GO

ALTER TABLE LoadToEquip.LoadToEquipment WITH NOCHECK
ADD CONSTRAINT FK_LoadToEquip_LoadToEquipment_OriginMarketID_Reference_Market_MarketID
    FOREIGN KEY ( OriginMarketID )
    REFERENCES Reference.Market ( MarketID ) 
PRINT '- FK [FK_LoadToEquip_LoadToEquipment_OriginMarketID_Reference_Market_MarketID] Created';

ALTER TABLE LoadToEquip.LoadToEquipment CHECK CONSTRAINT FK_LoadToEquip_LoadToEquipment_OriginMarketID_Reference_Market_MarketID;
PRINT '- FK [FK_LoadToEquip_LoadToEquipment_OriginMarketID_Reference_Market_MarketID] Enabled';
GO

--===================================================================================================
--[CREATE NON CLUSTERED INDEX]
--===================================================================================================
PRINT '******************************';
PRINT '*** Create Non Clustered Index ***';
PRINT '******************************';

--************************************************
PRINT 'Working on table [LoadToEquip].[LoadToEquipment] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'IX_LoadToEquip_LoadToEquipment_OriginMarketID_DestMarketID_EquipmentCategoryCode_Incl' )
BEGIN
    DROP INDEX IX_LoadToEquip_LoadToEquipment_OriginMarketID_DestMarketID_EquipmentCategoryCode_Incl ON LoadToEquip.LoadToEquipment;
	PRINT '- Index [IX_LoadToEquip_LoadToEquipment_OriginMarketID_DestMarketID_EquipmentCategoryCode_Incl] Dropped';
END;

CREATE NONCLUSTERED INDEX [IX_LoadToEquip_LoadToEquipment_OriginMarketID_DestMarketID_EquipmentCategoryCode_Incl] 
ON [LoadToEquip].[LoadToEquipment] 
(
	[OriginMarketID],
	[DestMarketID],
	[EquipmentCategoryCode]
)
INCLUDE 
( [LoadToEquipmentRatio]
, [RecordedDate]
, [EquipmentCount]
, [LoadCount]
) 
GO

PRINT '- Index [IX_LoadToEquip_LoadToEquipment_OriginMarketID_DestMarketID_EquipmentCategoryCode_Incl] Created';

--===================================================================================================
--[UPDATE STATS]
--===================================================================================================
PRINT '********************';
PRINT '*** Update Stats ***';
PRINT '********************';

--************************************************
PRINT 'Working on table [LoadToEquip].[LoadToEquipment] ...';

UPDATE STATISTICS LoadToEquip.LoadToEquipment;
PRINT '- Statistics Updated';


--===================================================================================================
--[DONE]
--===================================================================================================
PRINT '***********************';
PRINT '!!! Script COMPLETE !!!';
PRINT '***********************';
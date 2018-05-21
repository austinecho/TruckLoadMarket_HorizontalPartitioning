/*
DataTeam
TruckLoadMarket Partitioning

DBA:
-Monitor Transaction Logs and Blocking throughout process

•	DROP PK w/if exist (Result Heap on all table in set)
•	ADD Partition Column and Back Fill Data
•	ADD Clustered
•	ADD PK
•	Update Stats
	(The final state will be verified in a different step)

Run in DB02VPRD Equivilant 
*/
USE TruckLoadMarket;
GO

--===================================================================================================
--[START]
--===================================================================================================
PRINT '********************';
PRINT '!!! Script START !!!';
PRINT '********************';

IF ( SELECT @@SERVERNAME
   ) = 'DB02VPRD'
    BEGIN
        PRINT 'Running in Environment DB02VPRD...';
        END;
ELSE
    IF ( SELECT @@SERVERNAME
       ) = 'QA4-DB02'
        BEGIN
            PRINT 'Running in Environment QA4-DB02...';
            END;
    ELSE
        IF ( SELECT @@SERVERNAME
           ) = 'DATATEAM4-DB02'
            BEGIN
                PRINT 'Running in Environment DATATEAM4-DB02...';
                END;
        ELSE
            BEGIN
                PRINT 'ERROR: Server name not found. Process stopped.';
                    RETURN;
                END;


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

IF EXISTS ( SELECT  1
            FROM    sys.objects
            WHERE   type_desc = 'PRIMARY_KEY_CONSTRAINT'
                    AND parent_object_id = OBJECT_ID(N'LoadToEquip.LoadToEquipment')
                    AND name = N'PK__LoadToEq__0A6E807B7F60ED59' )
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
					AND  name = N'PK__LoadToEq__0A6E807B7F60ED59'
			  )
	BEGIN    
		ALTER TABLE LoadToEquip.LoadToEquipment DROP CONSTRAINT PK__LoadToEq__0A6E807B7F60ED59;
		PRINT '- PK [PK__LoadToEq__0A6E807B7F60ED59] Dropped';
	END;
END

--===================================================================================================
--[CREATE CLUSTERED INDEX]
--===================================================================================================
PRINT '******************************';
PRINT '*** Create Clustered Index ***';
PRINT '******************************';

--************************************************
PRINT 'Working on table [LoadToEquip].[LoadToEquipment] ...';

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'CIX_LoadToEquip_LoadToEquipment_RecordedDate' )
    BEGIN
        DROP INDEX CIX_LoadToEquip_LoadToEquipment_RecordedDate ON LoadToEquip.LoadToEquipment;
        PRINT '- Index [CIX_LoadToEquip_LoadToEquipment_RecordedDate] Dropped';
    END;

CREATE CLUSTERED INDEX CIX_LoadToEquip_LoadToEquipment_RecordedDate
ON LoadToEquip.LoadToEquipment ( RecordedDate ASC ) ON [PRIMARY];
PRINT '- Index [CIX_LoadToEquip_LoadToEquipment_RecordedDate] Created';

--===================================================================================================
--[CREATE PKs]
--===================================================================================================
PRINT '******************';
PRINT '*** Create PKs ***';
PRINT '******************';

--************************************************
PRINT 'Working on table [LoadToEquip].[LoadToEquipment] ...';

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'PK_LoadToEquip_LoadToEquipment_LoadToEquipmentID_RecordedDate' )
    BEGIN
        ALTER TABLE LoadToEquip.LoadToEquipment DROP CONSTRAINT PK_LoadToEquip_LoadToEquipment_LoadToEquipmentID_RecordedDate;
        PRINT '- PK [PK_LoadToEquip_LoadToEquipment_LoadToEquipmentID_RecordedDate] Dropped';
    END;

ALTER TABLE LoadToEquip.LoadToEquipment
ADD CONSTRAINT PK_LoadToEquip_LoadToEquipment_LoadToEquipmentID_RecordedDate
PRIMARY KEY NONCLUSTERED ( LoadToEquipmentID, RecordedDate ) ON [PRIMARY];
PRINT '- PK [PK_LoadToEquip_LoadToEquipment_LoadToEquipmentID_RecordedDate] Created';

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
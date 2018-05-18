/*
DataTeam
TruckLoadMarket Partitioning

•	ADD New File Group
•	ADD 2 Partition Functions
•	ADD 2 Partition Schemes

Run in DB01VPRD Equivalent
*/
USE TruckLoadMarket;
GO

IF ( SELECT @@SERVERNAME ) = 'DB01VPRD' BEGIN PRINT 'Running in Environment DB01VPRD...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'QA4-DB01' BEGIN PRINT 'Running in Environment QA4-DB01...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01' BEGIN PRINT 'Running in Environment DATATEAM4-DB01\DB01...'; END;
ELSE BEGIN PRINT 'ERROR: Server name not found. Process stopped.'; RETURN; END;

--===================================================================================================
--ADD FILEGROUP
--===================================================================================================
PRINT '*** ADD FILE GROUP AND FILE***';

IF NOT EXISTS ( SELECT 1 FROM sys.filegroups WHERE name = 'TruckLoadMarket_Archive' )
BEGIN 
	ALTER DATABASE TruckLoadMarket ADD FILEGROUP TruckLoadMarket_Archive;

	IF ( SELECT @@SERVERNAME ) = 'DB01VPRD'
	BEGIN
		--PROD --Note: N:\Data\EchoTrak.MDF --PRIMARY
		ALTER DATABASE TruckLoadMarket ADD FILE ( NAME = 'TruckLoadMarket_Archive', FILENAME = N'N:\Data\TruckLoadMarket_Archive.NDF', SIZE = 6GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1GB )
		TO FILEGROUP TruckLoadMarket_Archive;
	END;
	ELSE IF ( SELECT @@SERVERNAME ) = 'QA4-DB01'
	BEGIN
		--QA4 --Note: N:\Data\EchoTrak.MDF --PRIMARY
		ALTER DATABASE TruckLoadMarket ADD FILE ( NAME = 'TruckLoadMarket_Archive', FILENAME = N'N:\Data\TruckLoadMarket_Archive.NDF', SIZE = 6GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1GB )
		TO FILEGROUP TruckLoadMarket_Archive;
	END;
	ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01'
	BEGIN
		--DEV DT4 --Note: D:\Data\EchoTrak\EchoTrak_Primary.mdf --PRIMARY
		ALTER DATABASE TruckLoadMarket ADD FILE ( NAME = 'TruckLoadMarket_Archive', FILENAME = N'D:\Data\TruckLoadMarket_Archive.NDF', SIZE = 6GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1GB )
		TO FILEGROUP TruckLoadMarket_Archive;
		PRINT '- File [TruckLoadMarket_Archive] added';
	END;

	PRINT '- Filegroup [TruckLoadMarket_Archive] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Filegroup with same name already exists !!';
END;
GO

--===================================================================================================
--ADD PARTITION FUNCTION
--===================================================================================================
PRINT '*** ADD PARTITION FUNCTION ***';

IF NOT EXISTS ( SELECT 1 FROM sys.partition_functions WHERE name = 'PF_TruckLoadMarket_DATETIME_1Year' )
BEGIN
    CREATE PARTITION FUNCTION PF_TruckLoadMarket_DATETIME_1Year ( DATETIME ) AS RANGE RIGHT FOR VALUES ( '2017-01-01 00:00:00.000' ); 

    PRINT '- Partition Function [PF_TruckLoadMarket_DATETIME_1Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Function with same name already exists !!';
END;
GO

--===================================================================================================
--ADD PARTITION SCHEME
--===================================================================================================
PRINT '*** ADD PARTITION SCHEME ***';

IF NOT EXISTS ( SELECT 1 FROM sys.partition_schemes WHERE name = 'PS_TruckLoadMarket_DATETIME_1Year' )
BEGIN
    CREATE PARTITION SCHEME PS_TruckLoadMarket_DATETIME_1Year AS PARTITION PF_TruckLoadMarket_DATETIME_1Year TO ( TruckLoadMarket_Archive, [PRIMARY] );

	PRINT '- Partition Scheme [PS_TruckLoadMarket_DATETIME_1Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Scheme with same name already exists !!';
END;
GO

--Verify: Check existance
/*
SELECT * FROM sys.partition_functions WHERE name = 'PF_TruckLoadMarket_DATETIME_1Year';

SELECT * FROM sys.partition_schemes WHERE name = 'PS_TruckLoadMarket_DATETIME_1Year';

SELECT * FROM sys.filegroups WHERE name = 'TruckLoadMarket_Archive'

*/



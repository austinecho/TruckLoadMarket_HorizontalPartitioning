/*
DataTeam
databaseName Partitioning

•	ADD New File Group
•	ADD 2 Partition Functions
•	ADD 2 Partition Schemes

Run in DB01VPRD Equivalent
*/
USE databaseName;
GO

IF ( SELECT @@SERVERNAME ) = 'DB01VPRD' BEGIN PRINT 'Running in Environment DB01VPRD...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'QA4-DB01' BEGIN PRINT 'Running in Environment QA4-DB01...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01' BEGIN PRINT 'Running in Environment DATATEAM4-DB01\DB01...'; END;
ELSE BEGIN PRINT 'ERROR: Server name not found. Process stopped.'; RETURN; END;

--===================================================================================================
--ADD FILEGROUP
--===================================================================================================
PRINT '*** ADD FILE GROUP AND FILE***';

IF NOT EXISTS ( SELECT 1 FROM sys.filegroups WHERE name = '$databaseName_Archive' )
BEGIN 
	ALTER DATABASE databaseName ADD FILEGROUP databaseName_Archive;

	IF ( SELECT @@SERVERNAME ) = 'DB01VPRD'
	BEGIN
		--PROD --Note: N:\Data\EchoTrak.MDF --PRIMARY
		ALTER DATABASE databaseName ADD FILE ( NAME = 'databaseName_Archive', FILENAME = N'N:\Data\databaseName_Archive.NDF', SIZE = 6GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1GB )
		TO FILEGROUP databaseName_Archive;
	END;
	ELSE IF ( SELECT @@SERVERNAME ) = 'QA4-DB01'
	BEGIN
		--QA4 --Note: N:\Data\EchoTrak.MDF --PRIMARY
		ALTER DATABASE databaseName ADD FILE ( NAME = 'databaseName_Archive', FILENAME = N'N:\Data\databaseName_Archive.NDF', SIZE = 6GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1GB )
		TO FILEGROUP databaseName_Archive;
	END;
	ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01'
	BEGIN
		--DEV DT4 --Note: D:\Data\EchoTrak\EchoTrak_Primary.mdf --PRIMARY
		ALTER DATABASE databaseName ADD FILE ( NAME = 'databaseName_Archive', FILENAME = N'D:\Data\databaseName_Archive.NDF', SIZE = 6GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1GB )
		TO FILEGROUP databaseName_Archive;
		PRINT '- File [databaseName_Archive] added';
	END;

	PRINT '- Filegroup [databaseName_Archive] added';
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

IF NOT EXISTS ( SELECT 1 FROM sys.partition_functions WHERE name = 'PF_databaseName_DATETIME_2Year' )
BEGIN
    CREATE PARTITION FUNCTION PF_databaseName_DATETIME_2Year ( DATETIME ) AS RANGE RIGHT FOR VALUES ( '' ); 

    PRINT '- Partition Function [PF_databaseName_DATETIME_2Year] added';
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

IF NOT EXISTS ( SELECT 1 FROM sys.partition_schemes WHERE name = 'PS_databaseName_DATETIME_2Year' )
BEGIN
    CREATE PARTITION SCHEME PS_databaseName_DATETIME_2Year AS PARTITION PF_databaseName_DATETIME_2Year TO ( databaseName_Archive, [PRIMARY] );

	PRINT '- Partition Scheme [PS_databaseName_DATETIME_2Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Scheme with same name already exists !!';
END;
GO

--Verify: Check existance
/*
SELECT * FROM sys.partition_functions WHERE name = 'PF_databaseName_DATETIME_2Year';

SELECT * FROM sys.partition_schemes WHERE name = 'PS_databaseName_DATETIME_2Year';

SELECT * FROM sys.filegroups WHERE name = 'databaseName_Archive'

*/



/*
DataTeam
databaseName Partitioning

Remove table from replication, will add back after schema changes

Run in DB01VPRD Equivilant 
*/
USE databaseName;
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;  
GO 

exec sys.sp_dropsubscription @publication = 'PublicationdatabaseName',@article = 'dbo.tableName', @subscriber = N'all',@destination_db = N'all'
exec sp_droparticle @publication = 'PublicationdatabaseName', @article = 'dbo.tableName',@force_invalidate_snapshot = 0
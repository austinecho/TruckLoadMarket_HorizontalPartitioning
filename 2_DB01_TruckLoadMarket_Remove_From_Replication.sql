/*
DataTeam
databaseName Partitioning

Remove table from replication, will add back after schema changes

Run in DB01VPRD Equivilant 
*/
USE TruckLoadMarket;
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;  
GO 

EXEC sys.sp_dropsubscription @publication = 'PublicationTruckLoadMarket',@article ='LoadToEquip.LoadToEquipment', @subscriber = N'all', @destination_db = N'all'
EXEC sp_droparticle @publication = 'PublicationTruckLoadMarket', @article  ='LoadToEquip.LoadToEquipment', @force_invalidate_snapshot = 1 
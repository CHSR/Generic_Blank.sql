CREATE ROLE [db_executor]
AUTHORIZATION [dbo]
EXEC sp_addrolemember N'db_executor', N'CHSRAdmin'

EXEC sp_addrolemember N'db_executor', N'CHSRuser'
GRANT EXECUTE TO [db_executor]

GO

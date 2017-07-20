IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'CHSRUser')
CREATE LOGIN [CHSRUser] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [CHSRuser] FOR LOGIN [CHSRUser]
GO

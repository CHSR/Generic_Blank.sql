CREATE TABLE [dbo].[codeAuditC]
(
[codeAuditCPK] [int] NOT NULL IDENTITY(1, 1),
[codeGroup] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[codeScore] [int] NOT NULL,
[codeText] [char] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[codeValue] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeAuditC] ADD CONSTRAINT [PK_codeAuditC] PRIMARY KEY CLUSTERED  ([codeAuditCPK]) ON [PRIMARY]
GO

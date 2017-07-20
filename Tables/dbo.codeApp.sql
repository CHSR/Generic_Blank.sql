CREATE TABLE [dbo].[codeApp]
(
[codeAppPK] [int] NOT NULL IDENTITY(1, 1),
[AppCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AppCodeGroup] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AppCodeText] [char] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AppCodeUsedWhere] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeApp] ADD CONSTRAINT [PK__codeApp__6F38EFDF24927208] PRIMARY KEY CLUSTERED  ([codeAppPK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[codeForm]
(
[codeFormPK] [int] NOT NULL IDENTITY(1, 1),
[FormPKName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[canBeReviewed] [bit] NULL,
[codeFormAbbreviation] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[codeFormName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatorFieldName] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormDateName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MainTableName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeForm] ADD CONSTRAINT [PK__codeForm__C6B7B00D3B75D760] PRIMARY KEY CLUSTERED  ([codeFormPK]) ON [PRIMARY]
GO

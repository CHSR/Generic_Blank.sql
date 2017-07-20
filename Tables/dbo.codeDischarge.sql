CREATE TABLE [dbo].[codeDischarge]
(
[codeDischargePK] [int] NOT NULL IDENTITY(1, 1),
[DischargeCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DischargeReason] [char] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DischargeUsedWhere] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDischargeText] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeDischarge] ADD CONSTRAINT [PK__codeDisc__63BD1262300424B4] PRIMARY KEY CLUSTERED  ([codeDischargePK]) ON [PRIMARY]
GO

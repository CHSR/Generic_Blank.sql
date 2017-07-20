CREATE TABLE [dbo].[codeReportCatalog]
(
[codeReportCatalogPK] [int] NOT NULL IDENTITY(1, 1),
[CriteriaOptions] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Defaults] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Keywords] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldReportFK] [int] NULL,
[OldReportID] [nchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportCategory] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportClass] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDescription] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeReportCatalog] ADD CONSTRAINT [PK_codeReportCatalog] PRIMARY KEY CLUSTERED  ([codeReportCatalogPK]) ON [PRIMARY]
GO

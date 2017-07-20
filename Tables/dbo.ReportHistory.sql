CREATE TABLE [dbo].[ReportHistory]
(
[ReportHistoryPK] [int] NOT NULL IDENTITY(1, 1),
[ProgramFK] [int] NOT NULL,
[ReportCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportFK] [int] NOT NULL,
[ReportName] [char] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportType] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeRun] [datetime] NOT NULL,
[UserFK] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportFK_old] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportHistory] ADD CONSTRAINT [PK__ReportHi__488810E06BE40491] PRIMARY KEY CLUSTERED  ([ReportHistoryPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportHistory_TimeRun] ON [dbo].[ReportHistory] ([TimeRun]) ON [PRIMARY]
GO

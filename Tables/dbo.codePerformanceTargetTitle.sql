CREATE TABLE [dbo].[codePerformanceTargetTitle]
(
[codePerformanceTargetTitlePK] [int] NOT NULL IDENTITY(1, 1),
[PerformanceTargetCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PerformanceTargetCohortDescription] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PerformanceTargetDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PerformanceTargetSection] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PerformanceTargetTitle] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codePerformanceTargetTitle] ADD CONSTRAINT [PK_codePerformanceTargetTitles] PRIMARY KEY CLUSTERED  ([codePerformanceTargetTitlePK]) ON [PRIMARY]
GO

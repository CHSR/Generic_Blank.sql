CREATE TABLE [dbo].[codeRegion]
(
[codeRegionPK] [int] NOT NULL IDENTITY(1, 1),
[RegionDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegionName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeRegion] ADD CONSTRAINT [PK__codeRegi__61A492EE464ACD93] PRIMARY KEY CLUSTERED  ([codeRegionPK]) ON [PRIMARY]
GO

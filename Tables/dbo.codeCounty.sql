CREATE TABLE [dbo].[codeCounty]
(
[codeCountyPK] [int] NOT NULL IDENTITY(1, 1),
[CountyCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CountyName] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeCounty] ADD CONSTRAINT [PK__codeCoun__FC9855702C3393D0] PRIMARY KEY CLUSTERED  ([codeCountyPK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[listSite]
(
[listSitePK] [int] NOT NULL IDENTITY(1, 1),
[listSitePK_old] [int] NULL,
[ProgramFK] [int] NOT NULL,
[SiteCode] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SiteName] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[listSite] ADD CONSTRAINT [PK__listSite__CA09CAD83F115E1A] PRIMARY KEY CLUSTERED  ([listSitePK]) ON [PRIMARY]
GO

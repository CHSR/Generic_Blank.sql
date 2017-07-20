CREATE TABLE [dbo].[scoreASQSE]
(
[scoreASQSEPK] [int] NOT NULL IDENTITY(1, 1),
[ASQSEVersion] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MaximumASQSEScore] [numeric] (3, 0) NOT NULL,
[SocialEmotionalScore] [numeric] (6, 2) NOT NULL,
[TCAge] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[scoreASQSE] ADD CONSTRAINT [PK_scoreASQSE] PRIMARY KEY CLUSTERED  ([scoreASQSEPK]) ON [PRIMARY]
GO

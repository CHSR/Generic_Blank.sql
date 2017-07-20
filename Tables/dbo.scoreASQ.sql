CREATE TABLE [dbo].[scoreASQ]
(
[scoreASQPK] [int] NOT NULL IDENTITY(1, 1),
[ASQVersion] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommunicationScore] [numeric] (4, 2) NULL,
[FineMotorScore] [numeric] (4, 2) NULL,
[GrossMotorScore] [numeric] (4, 2) NULL,
[MaximumASQScore] [numeric] (3, 0) NULL,
[PersonalScore] [numeric] (4, 2) NULL,
[ProblemSolvingScore] [numeric] (4, 2) NULL,
[TCAge] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[scoreASQ] ADD CONSTRAINT [PK__scoreASQ__BAF7FD2D6FB49575] PRIMARY KEY CLUSTERED  ([scoreASQPK]) ON [PRIMARY]
GO

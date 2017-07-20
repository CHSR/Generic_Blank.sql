CREATE TABLE [dbo].[codeTopic]
(
[codeTopicPK] [int] NOT NULL IDENTITY(1, 1),
[TopicName] [char] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TopicCode] [numeric] (4, 1) NOT NULL,
[TopicPK_old] [int] NULL,
[SATCompareDateField] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SATInterval] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SATName] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SATReqBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaysAfter] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeTopic] ADD CONSTRAINT [PK_codeTopic] PRIMARY KEY CLUSTERED  ([codeTopicPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TopicCode] ON [dbo].[codeTopic] ([TopicCode]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[listFrequentlyAskedQuestion]
(
[listFrequentlyAskedQuestionPK] [int] NOT NULL IDENTITY(1, 1),
[Category] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Question] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Answer] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CategoryPosition] [int] NULL,
[QuestionPosition] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[listFrequentlyAskedQuestion] ADD CONSTRAINT [PK_listFrequentlyAskedQuestion] PRIMARY KEY CLUSTERED  ([listFrequentlyAskedQuestionPK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[FormReview]
(
[FormReviewPK] [int] NOT NULL IDENTITY(1, 1),
[FormDate] [datetime] NOT NULL,
[FormFK] [int] NOT NULL,
[FormReviewCreateDate] [datetime] NOT NULL CONSTRAINT [DF_FormReview_FormReviewCreateDate] DEFAULT (getdate()),
[FormReviewCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormReviewEditDate] [datetime] NULL,
[FormReviewEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVCaseFK] [int] NULL,
[ProgramFK] [int] NOT NULL,
[ReviewDateTime] [datetime] NULL,
[ReviewedBy] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_FormReviewEditDate ON FormReview
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_FormReviewEditDate] ON [dbo].[FormReview]
For Update 
AS
Update FormReview Set FormReview.FormReviewEditDate= getdate()
From [FormReview] INNER JOIN Inserted ON [FormReview].[FormReviewPK]= Inserted.[FormReviewPK]
GO
ALTER TABLE [dbo].[FormReview] ADD CONSTRAINT [PK__FormRevi__31992EDB76969D2E] PRIMARY KEY CLUSTERED  ([FormReviewPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FormReview_FormDate_FormFK_FormType] ON [dbo].[FormReview] ([FormDate], [FormFK], [FormType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FormReview_FormFK] ON [dbo].[FormReview] ([FormFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FormReview_FormType] ON [dbo].[FormReview] ([FormType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FormReview_HVCaseFK] ON [dbo].[FormReview] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FormReview_ProgramFK] ON [dbo].[FormReview] ([ProgramFK]) ON [PRIMARY]
GO

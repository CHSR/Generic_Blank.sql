CREATE TABLE [dbo].[Attachment]
(
[AttachmentPK] [int] NOT NULL IDENTITY(1, 1),
[Attachment] [varbinary] (max) NULL,
[AttachmentCreateDate] [datetime] NULL CONSTRAINT [DF_Attachment_AttachmentCreateDate] DEFAULT (getdate()),
[AttachmentCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttachmentDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttachmentFilePath] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttachmentTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormDate] [datetime] NOT NULL,
[FormFK] [int] NULL,
[FormType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVCaseFK] [int] NULL,
[ProgramFK] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Attachment] ADD CONSTRAINT [PK_Attachment] PRIMARY KEY CLUSTERED  ([AttachmentPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Attachment_FormFK] ON [dbo].[Attachment] ([FormFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Attachment_HVCaseFK] ON [dbo].[Attachment] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Attachment_ProgramFK] ON [dbo].[Attachment] ([ProgramFK]) ON [PRIMARY]
GO

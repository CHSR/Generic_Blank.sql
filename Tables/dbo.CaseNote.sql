CREATE TABLE [dbo].[CaseNote]
(
[CaseNotePK] [int] NOT NULL IDENTITY(1, 1),
[CaseNoteContents] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseNoteCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CaseNotes_CaseNotesCreateDate] DEFAULT (getdate()),
[CaseNoteCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseNoteDate] [date] NULL,
[CaseNoteEditDate] [datetime] NULL,
[CaseNoteEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_CaseNoteEditDate ON CaseNote
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
create TRIGGER [dbo].[TR_CaseNoteEditDate] ON [dbo].[CaseNote]
For Update 
AS
Update CaseNote set CaseNote.CaseNoteEditDate= getdate()
From [CaseNote] INNER JOIN Inserted ON [CaseNote].[CaseNotePK]= Inserted.[CaseNotePK]
GO
ALTER TABLE [dbo].[CaseNote] ADD CONSTRAINT [PK_CaseNotes] PRIMARY KEY CLUSTERED  ([CaseNotePK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[codeMedicalItem]
(
[codeMedicalItemPK] [int] NOT NULL IDENTITY(1, 1),
[MedicalItemCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalItemGroup] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalItemText] [char] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalItemTitle] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalItemUsedWhere] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NeedsDescription] [bit] NULL,
[Inactive] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeMedicalItem] ADD CONSTRAINT [PK__codeMedi__B481433146E78A0C] PRIMARY KEY CLUSTERED  ([codeMedicalItemPK]) ON [PRIMARY]
GO

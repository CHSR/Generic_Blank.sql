CREATE TABLE [dbo].[HVGroup]
(
[HVGroupPK] [int] NOT NULL IDENTITY(1, 1),
[ActivityTopic] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FAModerator1] [int] NOT NULL,
[FAModerator2] [int] NULL,
[GroupCreateDate] [datetime] NOT NULL CONSTRAINT [DF_HVGroup_GroupCreateDate] DEFAULT (getdate()),
[GroupCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GroupDate] [datetime] NOT NULL,
[GroupEditDate] [datetime] NULL,
[GroupEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupLengthHours] [int] NOT NULL,
[GroupLengthMinutes] [int] NOT NULL,
[GroupTime] [datetime] NOT NULL,
[GroupTitle] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVGroupPK_old] [int] NOT NULL,
[NumberParticipating] [int] NULL,
[ProgramFK] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_GroupEditDate ON HVGroup
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_GroupEditDate] ON [dbo].[HVGroup]
For Update 
AS
Update HVGroup Set HVGroup.GroupEditDate= getdate()
From [HVGroup] INNER JOIN Inserted ON [HVGroup].[HVGroupPK]= Inserted.[HVGroupPK]
GO
ALTER TABLE [dbo].[HVGroup] ADD CONSTRAINT [PK__HVGroup__01AEB03604E4BC85] PRIMARY KEY CLUSTERED  ([HVGroupPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVGroup_ProgramFK] ON [dbo].[HVGroup] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HVGroup] WITH NOCHECK ADD CONSTRAINT [FK_HVGroup_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO

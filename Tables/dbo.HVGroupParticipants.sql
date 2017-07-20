CREATE TABLE [dbo].[HVGroupParticipants]
(
[HVGroupParticipantsPK] [int] NOT NULL IDENTITY(1, 1),
[HVGroupFK] [int] NOT NULL,
[GroupFatherFigureFK] [int] NOT NULL,
[HVCaseFK] [int] NULL,
[HVGroupParticipantsCreateDate] [datetime] NOT NULL CONSTRAINT [DF_HVGroupParticipants_HVGroupParticipantsCreateDate] DEFAULT (getdate()),
[HVGroupParticipantsCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVGroupParticipantsEditDate] [datetime] NULL,
[HVGroupParticipantsEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NULL,
[PCFK] [int] NULL,
[RoleType] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_HVGroupParticipantsEditDate ON HVGroupParticipants
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_HVGroupParticipantsEditDate] ON [dbo].[HVGroupParticipants]
For Update 
AS
Update HVGroupParticipants Set HVGroupParticipants.HVGroupParticipantsEditDate= getdate()
From [HVGroupParticipants] INNER JOIN Inserted ON [HVGroupParticipants].[HVGroupParticipantsPK]= Inserted.[HVGroupParticipantsPK]
GO
ALTER TABLE [dbo].[HVGroupParticipants] ADD CONSTRAINT [PK__HVGroupP__C00CEB2009A971A2] PRIMARY KEY CLUSTERED  ([HVGroupParticipantsPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVGroupParticipants_GroupFatherFigureFK] ON [dbo].[HVGroupParticipants] ([GroupFatherFigureFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVGroupParticipants_HVGroupFK] ON [dbo].[HVGroupParticipants] ([HVGroupFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVGroupParticipants_ProgramFK] ON [dbo].[HVGroupParticipants] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HVGroupParticipants] WITH NOCHECK ADD CONSTRAINT [FK_HVGroupParticipants_GroupFatherFigureFK] FOREIGN KEY ([GroupFatherFigureFK]) REFERENCES [dbo].[PC] ([PCPK])
GO
ALTER TABLE [dbo].[HVGroupParticipants] WITH NOCHECK ADD CONSTRAINT [FK_HVGroupParticipants_HVGroupFK] FOREIGN KEY ([HVGroupFK]) REFERENCES [dbo].[HVGroup] ([HVGroupPK])
GO
ALTER TABLE [dbo].[HVGroupParticipants] WITH NOCHECK ADD CONSTRAINT [FK_HVGroupParticipants_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO

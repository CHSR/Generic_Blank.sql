CREATE TABLE [dbo].[listMedicalFacility]
(
[listMedicalFacilityPK] [int] NOT NULL IDENTITY(1, 1),
[MFAddress] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MFCity] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MFCreateDate] [datetime] NOT NULL CONSTRAINT [DF_listMedicalFacility_MFCreateDate] DEFAULT (getdate()),
[MFCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MFEditDate] [datetime] NULL,
[MFEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MFIsActive] [bit] NULL,
[MFName] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MFPhone] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MFState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MFZip] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_MFEditDate ON listMedicalFacility
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_MFEditDate] ON [dbo].[listMedicalFacility]
For Update 
AS
Update listMedicalFacility Set listMedicalFacility.MFEditDate= getdate()
From [listMedicalFacility] INNER JOIN Inserted ON [listMedicalFacility].[listMedicalFacilityPK]= Inserted.[listMedicalFacilityPK]
GO
ALTER TABLE [dbo].[listMedicalFacility] ADD CONSTRAINT [PK__listMedi__3205CD4C2DE6D218] PRIMARY KEY CLUSTERED  ([listMedicalFacilityPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_listMedicalFacility_ProgramFK] ON [dbo].[listMedicalFacility] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[listMedicalFacility] WITH NOCHECK ADD CONSTRAINT [FK_listMedicalFacility_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO

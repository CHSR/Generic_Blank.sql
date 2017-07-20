CREATE TABLE [dbo].[HVProgram]
(
[HVProgramPK] [int] NOT NULL IDENTITY(1, 1),
[ContractEndDate] [datetime] NULL,
[ContractManager] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractNumber] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractStartDate] [datetime] NULL,
[CountyFK] [int] NULL,
[ExtraField1Description] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField2Description] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField3Description] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField4Description] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField5Description] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField7Description] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField8Description] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField9Description] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GrantAmount] [numeric] (10, 2) NULL,
[HVProgramCreateDate] [datetime] NOT NULL CONSTRAINT [DF_HVProgram_HVProgramCreateDate] DEFAULT (getdate()),
[HVProgramCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVProgramEditDate] [datetime] NULL,
[HVProgramEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadAgencyCity] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadAgencyDirector] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadAgencyName] [char] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadAgencyStreet] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadAgencyZip] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModemNumber] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramCapacity] [int] NULL,
[ProgramCity] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramCode] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFaxNumber] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramManager] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramName] [char] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramPhone] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramStreet] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramZip] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegionFK] [int] NULL,
[TargetZip] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_HVProgramEditDate ON HVProgram
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_HVProgramEditDate] ON [dbo].[HVProgram]
For Update 
AS
Update HVProgram Set HVProgram.HVProgramEditDate= getdate()
From [HVProgram] INNER JOIN Inserted ON [HVProgram].[HVProgramPK]= Inserted.[HVProgramPK]
GO
ALTER TABLE [dbo].[HVProgram] ADD CONSTRAINT [PK__HVProgra__1C343B0217036CC0] PRIMARY KEY CLUSTERED  ([HVProgramPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVProgram_CountyFK] ON [dbo].[HVProgram] ([CountyFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HVProgram] WITH NOCHECK ADD CONSTRAINT [FK_HVProgram_CountyFK] FOREIGN KEY ([CountyFK]) REFERENCES [dbo].[codeCounty] ([codeCountyPK])
GO

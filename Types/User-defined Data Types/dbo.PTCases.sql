CREATE TYPE [dbo].[PTCases] AS TABLE
(
[HVCaseFK] [int] NOT NULL,
[CaseProgramPK] [int] NOT NULL,
[PC1ID] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OldID] [varchar] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1FullName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CurrentWorkerFK] [int] NOT NULL,
[CurrentWorkerFullName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CurrentLevelName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL,
[TCIDPK] [int] NULL,
[TCDOB] [datetime] NULL
)
GO

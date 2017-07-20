CREATE TABLE [dbo].[codeERHospitalReasons]
(
[codeERHospitalReasonsPK] [int] NOT NULL IDENTITY(1, 1),
[ReasonCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReasonDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReasonGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeERHospitalReasons] ADD CONSTRAINT [PK__codeERHo__2E3770F237A5467C] PRIMARY KEY CLUSTERED  ([codeERHospitalReasonsPK]) ON [PRIMARY]
GO

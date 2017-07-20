CREATE TABLE [dbo].[codeServiceReferral]
(
[codeServiceReferralPK] [int] NOT NULL IDENTITY(1, 1),
[ServiceReferralCategory] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServiceReferralCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServiceReferralType] [char] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeServiceReferral] ADD CONSTRAINT [PK__codeServ__59B9592A4E88ABD4] PRIMARY KEY CLUSTERED  ([codeServiceReferralPK]) ON [PRIMARY]
GO

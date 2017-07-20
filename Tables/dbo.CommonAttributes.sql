CREATE TABLE [dbo].[CommonAttributes]
(
[CommonAttributesPK] [int] NOT NULL IDENTITY(1, 1),
[AvailableMonthlyBenefits] [numeric] (4, 0) NULL,
[AvailableMonthlyBenefitsUnknown] [bit] NULL,
[AvailableMonthlyIncome] [numeric] (5, 0) NULL,
[CommonAttributesCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CommonAttributes_CommonAttributesCreateDate] DEFAULT (getdate()),
[CommonAttributesCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommonAttributesEditDate] [datetime] NULL,
[CommonAttributesEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EducationalEnrollment] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormDate] [datetime] NOT NULL,
[FormFK] [int] NULL,
[FormInterval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormType] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Gravida] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HIFamilyChildHealthPlus] [bit] NULL,
[HighestGrade] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HIMedicaidCaseNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HIOther] [bit] NULL,
[HIOtherSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HIPCAP] [bit] NULL,
[HIPCAPCaseNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HIPrivate] [bit] NULL,
[HIUninsured] [bit] NULL,
[HIUnknown] [bit] NULL,
[HoursPerMonth] [int] NULL,
[HVCaseFK] [int] NOT NULL,
[IsCurrentlyEmployed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LanguageSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Looked4Employment] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaritalStatus] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MonthlyIncomeUnknown] [bit] NULL,
[NumberEmployed] [int] NULL,
[NumberInHouse] [int] NULL,
[OBPInHome] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBPInvolvement] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBPInvolvementSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parity] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBEmergencyAssistance] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBEmergencyAssistanceAmount] [numeric] (4, 0) NULL,
[PBFoodStamps] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBFoodStampsAmount] [numeric] (4, 0) NULL,
[PBSSI] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBSSIAmount] [numeric] (4, 0) NULL,
[PBTANF] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBTANFAmount] [numeric] (4, 0) NULL,
[PBWIC] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBWICAmount] [numeric] (4, 0) NULL,
[PC1HasMedicalProvider] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1MedicalFacilityFK] [int] NULL,
[PC1MedicalProviderFK] [int] NULL,
[PC1ReceivingMedicaid] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCFK] [int] NULL,
[PreviouslyEmployed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryLanguage] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[ReceivingPreNatalCare] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceivingPublicBenefits] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SIDomesticViolence] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SICPSACS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SIMentalHealth] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SISubstanceAbuse] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TANFServices] [bit] NULL,
[TANFServicesNo] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TANFServicesNoSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TCHasMedicalProvider] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TCHIFamilyChildHealthPlus] [bit] NULL,
[TCHIMedicaidCaseNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TCHIPrivateInsurance] [bit] NULL,
[TCHIOther] [bit] NULL,
[TCHIOtherSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TCHIUninsured] [bit] NULL,
[TCHIUnknown] [bit] NULL,
[TCMedicalFacilityFK] [int] NULL,
[TCMedicalProviderFK] [int] NULL,
[TCReceivingMedicaid] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeBreastFed] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WasBreastFed] [bit] NULL,
[WhyNotBreastFed] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LivingArrangement] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LivingArrangementSpecific] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TCMedicalCareSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TCMedicalCareSourceOtherSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_CommonAttributesEditDate ON CommonAttributes
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_CommonAttributesEditDate] ON [dbo].[CommonAttributes]
For Update 
AS
Update CommonAttributes Set CommonAttributes.CommonAttributesEditDate= getdate()
From [CommonAttributes] INNER JOIN Inserted ON [CommonAttributes].[CommonAttributesPK]= Inserted.[CommonAttributesPK]
GO
ALTER TABLE [dbo].[CommonAttributes] ADD CONSTRAINT [PK__CommonAt__14761E7359FA5E80] PRIMARY KEY CLUSTERED  ([CommonAttributesPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CommonAttributes_HVCaseFK] ON [dbo].[CommonAttributes] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CommonAttributes_PC1MedicalFacilityFK] ON [dbo].[CommonAttributes] ([PC1MedicalFacilityFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CommonAttributes_PC1MedicalProviderFK] ON [dbo].[CommonAttributes] ([PC1MedicalProviderFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CommonAttributes_PCFK] ON [dbo].[CommonAttributes] ([PCFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CommonAttributes_ProgramFK] ON [dbo].[CommonAttributes] ([ProgramFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CommonAttributes_TCMedicalFacilityFK] ON [dbo].[CommonAttributes] ([TCMedicalFacilityFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CommonAttributes_TCMedicalProviderFK] ON [dbo].[CommonAttributes] ([TCMedicalProviderFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CommonAttributes] ADD CONSTRAINT [FK_CommonAttributes_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[CommonAttributes] ADD CONSTRAINT [FK_CommonAttributes_PC1MedicalFacilityFK] FOREIGN KEY ([PC1MedicalFacilityFK]) REFERENCES [dbo].[listMedicalFacility] ([listMedicalFacilityPK])
GO
ALTER TABLE [dbo].[CommonAttributes] ADD CONSTRAINT [FK_CommonAttributes_PC1MedicalProviderFK] FOREIGN KEY ([PC1MedicalProviderFK]) REFERENCES [dbo].[listMedicalProvider] ([listMedicalProviderPK])
GO
ALTER TABLE [dbo].[CommonAttributes] ADD CONSTRAINT [FK_CommonAttributes_PCFK] FOREIGN KEY ([PCFK]) REFERENCES [dbo].[PC] ([PCPK])
GO
ALTER TABLE [dbo].[CommonAttributes] ADD CONSTRAINT [FK_CommonAttributes_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[CommonAttributes] ADD CONSTRAINT [FK_CommonAttributes_TCMedicalFacilityFK] FOREIGN KEY ([TCMedicalFacilityFK]) REFERENCES [dbo].[listMedicalFacility] ([listMedicalFacilityPK])
GO
ALTER TABLE [dbo].[CommonAttributes] ADD CONSTRAINT [FK_CommonAttributes_TCMedicalProviderFK] FOREIGN KEY ([TCMedicalProviderFK]) REFERENCES [dbo].[listMedicalProvider] ([listMedicalProviderPK])
GO

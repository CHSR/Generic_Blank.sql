SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




create procedure [dbo].[spGetAllPC1MedicalbyHVCaseFK]
@HVCaseFK as int

as
select *
from dbo.PC1Medical pcm, dbo.codeMedicalItem cmi
where HVCaseFK=@HVCaseFK and pcm.PC1MedicalItem=cmi.MedicalItemCode
order by pcm.PC1MedicalItem



GO

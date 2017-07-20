SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: June 21, 2013
-- Description:	stored proc for the Screen Form report
-- exec rspScreenForm 'BB64010007068'
-- =============================================
CREATE proc [dbo].[rspScreenForm] (@PC1ID varchar(13))

as
begin

select PC1ID
		, rtrim(PCFirstName) + ' ' + rtrim(PCLastName) as ParentName
		, convert(varchar, PCDOB, 101) as PCDOB
		, TCDOB
		, convert(varchar, h.ScreenDate, 101) as ScreenDate
		, caRel.AppCodeText as Relation2TC
		, Relation2TCSpecify
		, rtrim(PCStreet) + 
			case when dbo.IsNullOrEmpty(PCApt) = '1' then '' else ', Apt: ' + rtrim(PCApt) end + 
			', ' + rtrim(PCCity) + ', ' + rtrim(PCState) + ' ' + rtrim(PCZip) as PC1Address
		, PCPhone
		, rtrim(ScreenerFirstName) + ' ' + rtrim(ScreenerLastName) as ScreenerName
		, ScreenerPhone
		, case when EDC is null and TCDOB is not null and TCDOB < s.ScreenDate 
				then 'Post' 
				else 'Pre'
				end
			+ 'natal'
			as PreOrPostNatal
		, case when EDC is null and TCDOB is not null 
				then 'TCDOB: ' + convert(varchar, TCDOB, 101) 
				else 'EDC: ' + convert(varchar, EDC, 101)
				end
			as TCDate
		, case when RiskNotMarried = '1' then 'T'
				when RiskNotMarried = '0' then 'F'
				else 'U'
			end
			as RiskNotMarried 
		, case when RiskNoPrenatalCare = '1' then 'T'
				when RiskNoPrenatalCare = '0' then 'F'
				else 'U'
			end
			as RiskNoPrenatalCare 
		, case when RiskInadequateSupports = '1' then 'T'
				when RiskInadequateSupports = '0' then 'F'
				else 'U'
			end
			as RiskInadequateSupports 
		, case when RiskUnder21 = '1' then 'T'
				when RiskUnder21 = '0' then 'F'
				else 'U'
			end
			as RiskUnder21 
		, ReferralSourceName
		, caRef.AppCodeText as ReferralSourceType
		, ReferralSourceSpecify
		, case when ScreenResult = '1' then 'Positive' else 'Negative' end as ScreenResult
		, case when ReferralMade = '1' then 'Yes'
				else 'No -- Reason: ' + 
					case when dbo.IsNullOrEmpty(s.DischargeReason) = '1' then 'Unknown / Blank' 
							when d.DischargeReason = 'Other' then 'Other; ' + s.DischargeReasonSpecify
							else d.DischargeReason
						end
				end 
			as ReferralMade
		, case when FAWFK is null then 'NO FAW Assigned' 
					else rtrim(FirstName) + ' ' + rtrim(LastName) 
			end 
			as FAWName
from HVScreen s 
inner join CaseProgram cp on cp.HVCaseFK = s.HVCaseFK
inner join HVCase h on h.HVCasePK = cp.HVCaseFK
inner join PC P on P.PCPK = h.PC1FK
left outer join codeApp caRel on Relation2TC = AppCode and caRel.AppCodeGroup = 'PCRelationToTC'
left outer join codeApp caRef on caRef.AppCode = ReferralSource and caRef.AppCodeGroup = 'TypeofReferral'
left outer join codeDischarge d on d.DischargeReason = s.DischargeReason
inner join listReferralSource rs on ReferralSourceFK = listReferralSourcePK
left outer join Worker w on w.WorkerPK = s.FAWFK
where PC1ID = @PC1ID

-- select * from HVScreen h where HVCaseFK = 7068
end
GO

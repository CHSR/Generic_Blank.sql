SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Edited On: 4-5-2017
--Edited by Chris Papas - removed function and removed the XML inner join to speed up search

-- 'AD85030196603'
-- exec spSearchCases null,null,'Allison','Dough'
CREATE procedure [dbo].[spSearchCases] (@PC1ID varchar(13) = null
									 , @PCPK int = null
									 , @PCFirstName varchar(20) = null
									 , @PCLastName varchar(30) = null
									 , @PCDOB datetime = null
									 , @TCFirstName varchar(20) = null
									 , @TCLastName varchar(30) = null
									 , @TCDOB datetime = null
									 , @WorkerPK int = null
									 , @ProgramFK int = null
									 , @HVCasePK int = null
									  )
as
	set nocount on;
	
		;with cteresults as (
	
			select HVCasePK
						  , PC.PCPK
						  , PC1ID
						  , PC.PCFirstName
						  , PC.PCLastName
						  , PC.PCOldName
						  , PC.PCOldName2
						  , PC.PCDOB
						  , rtrim(TCID.TCFirstName) as TCFirstName
						  , rtrim(TCID.TCLastName) as TCLastName
						  , hv.TCDOB
						  , rtrim(Worker.LastName) as workerlastname
						  , rtrim(Worker.FirstName) as workerfirstname
						  , IntakeDate
						  , DischargeDate
						  , rtrim(cast(CaseProgress as char(4))) + '-' + ccp.CaseProgressBrief as CaseProgress
						  , case when OBPFK is not null then 'Yes'
								 else 'No'
							end as CaseHasOBP
						  , case when PC2FK is not null then 'Yes'
								 else 'No'
							end as CaseHasPC2
						  , cdlvl.LevelName
						  , WorkerPK
				  from		CaseProgram cp WITH (NOLOCK) --no reason to lock since we're just searching
				  inner join codeLevel cdlvl on cdlvl.codeLevelPK = cp.CurrentLevelFK
				  inner join HVCase hv on cp.HVCaseFK = hv.HVCasePK
				  inner join PC on hv.PC1FK = PC.PCPK
				  inner join codeCaseProgress ccp on hv.CaseProgress = ccp.CaseProgressCode
				  left join TCID on TCID.HVCaseFK = hv.HVCasePK
				  left join WorkerProgram wp on wp.WorkerFK = isnull(CurrentFSWFK, CurrentFAWFK) --IN(currentfswfk, currentfawfk)
												and wp.ProgramFK = cp.ProgramFK
				  left join Worker on WorkerPK = WorkerFK
				  where		(PC1ID like '%' + @PC1ID + '%'
							 or PCPK = @PCPK
							 or PC.PCFirstName like @PCFirstName + '%'
							 or PC.PCOldName like @PCFirstName + '%'
							 or PC.PCOldName2 like @PCFirstName + '%'
							 or PC.PCLastName like @PCLastName + '%'
							 or PC.PCOldName like '%' + @PCLastName
							 or PC.PCOldName2 like '%' + @PCLastName
							 or PC.PCDOB = @PCDOB
							 or TCID.TCFirstName like @TCFirstName + '%'
							 or TCID.TCLastName like @TCLastName + '%'
							 or hv.TCDOB = @TCDOB
							 or WorkerPK = @WorkerPK
							 or HVCasePK = @HVCasePK
							)
							and cp.ProgramFK = isnull(@ProgramFK, cp.ProgramFK)
				 )
		select distinct	top 100 
				hvcasepk
			  , pcpk
			  , PC1ID
			  , pcfirstname + ' ' + pclastname as PC1
			  , pcOldName
			  , pcOldName2 
			  , pcdob
			  , tc = tcfirstname + ' ' + tclastname
			  , tcdob
			  , workerfirstname + ' ' + workerlastname as worker
			  , dischargedate
			  , intakedate
			  , caseprogress
			  , casehasobp
			  , casehaspc2
			  , levelname
			  , case when dischargedate is null then 0
					else 1
				end
			  , (case when PC1ID = @PC1ID then 1
						else 0
					end + 
				 case	when pcpk = @PCPK then 1
						else 0
					end + 
				case when pcfirstname like @PCFirstName + '%' then 1
					else 0
				end + 
				case when pclastname like @PCLastName + '%' then 1
					else 0
				end + 
				case when pcOldName like @PCFirstName + '%' then 1
					else 0
				end + 
				case when pcOldName2 like @PCFirstName + '%' then 1
					else 0
				end + 
				case when pcOldName like '%' + @PCLastName then 1
					else 0
				end + 
				case when pcOldName2 like '%' + @PCLastName then 1
					else 0
				end + 
				case when pcdob = @PCDOB then 1
					else 0
				end + 
				case when tcfirstname like @TCFirstName + '%' then 1
					else 0
				end + 
				case when tclastname like @TCLastName + '%' then 1
					else 0
				end + 
				case when tcdob = @TCDOB then 1
					else 0
				end + 
				case when WorkerPK = @WorkerPK then 1
					  else 0
				end + 
				case when HVCasePK = @HVCasePK then 1
					  else 0
				end) as Score4OrderingRows
		from	cteresults
		order by case when dischargedate is null then 0
					  else 1
				 end
			  , Score4OrderingRows desc
			  , PC1ID;
GO
